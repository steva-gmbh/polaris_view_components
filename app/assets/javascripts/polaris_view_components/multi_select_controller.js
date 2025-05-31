import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "buttonText", "optionList", "option"]
  static values = { selected: Array }

  connect() {
    // Initialize selected values from current checkbox states
    this.initializeSelectedValues()

    // Only update button text if we don't have any initial selections
    // This preserves the server-rendered button text for initial selections
    if (this.selectedValue.length === 0) {
      this.updateButtonText()
    }

    this.setupPopoverEventListeners()
  }

  disconnect() {
    if (this.popoverObserver) {
      this.popoverObserver.disconnect()
    }
  }

  initializeSelectedValues() {
    // Initialize from the data attribute set by the Ruby component
    const initialSelected = this.selectedValue || []
    this.selectedValue = [...initialSelected]
    this.initialSelectedValue = [...initialSelected] // Store initial state for comparison

    // Also sync with checkbox states for consistency
    setTimeout(() => {
      const checkboxSelected = []
      this.optionTargets.forEach(option => {
        const checkbox = option.querySelector('input[type="checkbox"]')
        if (checkbox && checkbox.checked) {
          const value = option.dataset.polarisMultiSelectValue
          checkboxSelected.push(value)
        }
      })

      // If checkboxes have different state than our initial data, use checkbox state
      if (checkboxSelected.length !== this.selectedValue.length ||
        !checkboxSelected.every(val => this.selectedValue.includes(val))) {
        this.selectedValue = checkboxSelected
        this.initialSelectedValue = [...checkboxSelected] // Update initial state
        this.updateButtonText()
      }
    }, 0)
  }

  setupPopoverEventListeners() {
    // Listen for popover state changes by observing class changes
    const popoverElement = this.element.querySelector('.Polaris-Popover__PopoverOverlay')
    if (popoverElement) {
      const observer = new MutationObserver((mutations) => {
        mutations.forEach((mutation) => {
          if (mutation.type === 'attributes' && mutation.attributeName === 'class') {
            const isOpen = popoverElement.classList.contains('Polaris-Popover__PopoverOverlay--open')
            const wasPreviouslyOpen = this.wasPopoverOpen

            if (isOpen && !wasPreviouslyOpen) {
              this.dispatchPopoverOpenedEvent()
              this.wasPopoverOpen = true
            } else if (!isOpen && wasPreviouslyOpen) {
              this.dispatchPopoverClosedEvent()
              this.wasPopoverOpen = false
            }
          }
        })
      })

      observer.observe(popoverElement, { attributes: true, attributeFilter: ['class'] })
      this.popoverObserver = observer
      this.wasPopoverOpen = popoverElement.classList.contains('Polaris-Popover__PopoverOverlay--open')
    }
  }

  // Actions

  toggle(event) {
    event.preventDefault()
    // The popover controller will handle the actual toggling
    // Popover open/close events are handled by the MutationObserver
  }

  toggleOption(event) {
    // If the event target is the checkbox itself, use it directly
    const checkbox = event.target.type === 'checkbox' ? event.target : event.currentTarget.querySelector('input[type="checkbox"]')
    const optionElement = checkbox.closest('[data-polaris-multi-select-target="option"]')
    const value = optionElement.dataset.polarisMultiSelectValue
    const text = optionElement.dataset.polarisMultiSelectText

    // Use a small delay to ensure checkbox state has been updated
    setTimeout(() => {
      if (checkbox.checked) {
        this.addSelection(value, text)
      } else {
        this.removeSelection(value)
      }

      this.updateButtonText()
      this.dispatchImmediateSelectionChangedEvent()
    }, 0)
  }

  // Private methods

  addSelection(value, text) {
    if (!this.selectedValue.includes(value)) {
      this.selectedValue = [...this.selectedValue, value]
    }
  }

  removeSelection(value) {
    this.selectedValue = this.selectedValue.filter(v => v !== value)
  }

  updateButtonText() {
    const buttonTextElement = this.buttonTextTarget

    if (this.selectedValue.length === 0) {
      buttonTextElement.textContent = this.getPlaceholderText()
    } else if (this.selectedValue.length === 1) {
      buttonTextElement.textContent = this.getOptionText(this.selectedValue[0])
    } else {
      const firstOptionText = this.getOptionText(this.selectedValue[0])
      const additionalCount = this.selectedValue.length - 1
      buttonTextElement.textContent = `${firstOptionText} +${additionalCount}`
    }
  }

  getOptionText(value) {
    const optionElement = this.optionTargets.find(option =>
      option.dataset.polarisMultiSelectValue === value
    )
    return optionElement ? optionElement.dataset.polarisMultiSelectText : value
  }

  getPlaceholderText() {
    // Get placeholder from data attribute or use default
    return this.element.dataset.placeholder || 'Select options'
  }

  // Event dispatching methods

  checkAndDispatchSelectionChange() {
    // Check if current selection is different from initial selection
    const hasChanged = this.hasSelectionChanged()

    if (hasChanged) {
      this.dispatchSelectionChangedEvent()
      // Update the initial state to the current state so we can detect future changes
      this.initialSelectedValue = [...this.selectedValue]
    }
  }

  hasSelectionChanged() {
    // Compare current selection with initial selection
    if (this.selectedValue.length !== this.initialSelectedValue.length) {
      return true
    }

    // Check if all values are the same (order doesn't matter)
    const currentSorted = [...this.selectedValue].sort()
    const initialSorted = [...this.initialSelectedValue].sort()

    return !currentSorted.every((value, index) => value === initialSorted[index])
  }

  dispatchImmediateSelectionChangedEvent() {
    const event = new CustomEvent('polaris-multi-select:immediateSelectionChanged', {
      detail: {
        selectedValues: [...this.selectedValue],
        selectedTexts: this.selectedValue.map(value => this.getOptionText(value)),
        count: this.selectedValue.length,
        hasChangedFromInitial: this.hasSelectionChanged()
      },
      bubbles: true
    })
    this.element.dispatchEvent(event)
  }

  dispatchSelectionChangedEvent() {
    const event = new CustomEvent('polaris-multi-select:selectionChanged', {
      detail: {
        selectedValues: [...this.selectedValue],
        selectedTexts: this.selectedValue.map(value => this.getOptionText(value)),
        count: this.selectedValue.length
      },
      bubbles: true
    })
    this.element.dispatchEvent(event)
  }

  dispatchPopoverOpenedEvent() {
    const event = new CustomEvent('polaris-multi-select:popoverOpened', {
      detail: {
        selectedValues: [...this.selectedValue],
        count: this.selectedValue.length
      },
      bubbles: true
    })
    this.element.dispatchEvent(event)
  }

  dispatchPopoverClosedEvent() {
    const event = new CustomEvent('polaris-multi-select:popoverClosed', {
      detail: {
        selectedValues: [...this.selectedValue],
        count: this.selectedValue.length
      },
      bubbles: true
    })
    this.element.dispatchEvent(event)

    // Check if selection has changed from initial state and dispatch selection change event
    this.checkAndDispatchSelectionChange()
  }
}
