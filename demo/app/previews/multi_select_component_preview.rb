class MultiSelectComponentPreview < ViewComponent::Preview
  def default
    render(Polaris::MultiSelectComponent.new(
      options: [
        ["Red", "red"],
        ["Green", "green"],
        ["Blue", "blue"],
        ["Yellow", "yellow"],
        ["Purple", "purple"]
      ],
      placeholder: "Choose colors"
    ))
  end

  def with_initial_selection
    render(Polaris::MultiSelectComponent.new(
      options: [
        ["Apple", "apple"],
        ["Banana", "banana"],
        ["Cherry", "cherry"],
        ["Date", "date"],
        ["Elderberry", "elderberry"]
      ],
      selected: ["apple", "cherry"],
      placeholder: "Select fruits",
      label: "Favorite fruits"
    ))
  end

  def with_form
    render(Polaris::MultiSelectComponent.new(
      options: [
        ["Small", "small"],
        ["Medium", "medium"],
        ["Large", "large"],
        ["Extra Large", "xl"]
      ],
      name: "sizes[]",
      placeholder: "Select sizes",
      label: "Available sizes",
      help_text: "Choose all applicable sizes"
    ))
  end

  def disabled_state
    render(Polaris::MultiSelectComponent.new(
      options: [
        ["Option 1", "1"],
        ["Option 2", "2"],
        ["Option 3", "3"]
      ],
      disabled: true,
      placeholder: "Cannot select",
      label: "Disabled select"
    ))
  end
end
