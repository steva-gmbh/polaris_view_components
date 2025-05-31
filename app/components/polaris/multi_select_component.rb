module Polaris
  class MultiSelectComponent < Polaris::Component
    def initialize(
      options: [],
      selected: [],
      placeholder: "Select options",
      name: nil,
      form: nil,
      attribute: nil,
      disabled: false,
      label: nil,
      label_hidden: false,
      label_inline: false,
      label_action: nil,
      help_text: nil,
      error: false,
      required: false,
      wrapper_arguments: {},
      **system_arguments
    )
      @options = options
      @selected = Array(selected)
      @placeholder = placeholder
      @name = name
      @form = form
      @attribute = attribute
      @disabled = disabled
      @label = label
      @label_hidden = label_hidden
      @label_inline = label_inline
      @help_text = help_text
      @error = error
      @required = required
      @system_arguments = system_arguments

      @system_arguments[:tag] = "div"
      @system_arguments[:data] ||= {}
      prepend_option(@system_arguments[:data], :controller, "polaris-multi-select")
      @system_arguments[:data][:polaris_multi_select_selected_value] = @selected
      @system_arguments[:data][:placeholder] = @placeholder
      @system_arguments[:classes] = class_names(
        @system_arguments[:classes],
        "Polaris-MultiSelect",
        "Polaris-MultiSelect--disabled": @disabled,
        "Polaris-MultiSelect--error": @error
      )

      @wrapper_arguments = {
        form: form,
        attribute: attribute,
        name: name,
        label: label,
        label_hidden: hides_label?,
        label_action: label_action,
        required: required,
        help_text: help_text,
        error: error
      }.merge(wrapper_arguments)
    end

    def hides_label?
      @label_hidden || @label_inline
    end

    def button_text
      return @placeholder if @selected.empty?
      return selected_option_text(@selected.first) if @selected.length == 1

      "#{selected_option_text(@selected.first)} +#{@selected.length - 1}"
    end

    def popover_id
      @popover_id ||= "multi-select-#{rand(10000)}"
    end

    def hidden_input_name
      return @name if @name
      return "#{@form.object_name}[#{@attribute}][]" if @form && @attribute

      "multi_select[]"
    end

    def checkbox_input_name
      # For checkboxes, we want the same name as hidden inputs
      # but if it doesn't end with [], we should add it for multi selections
      name = hidden_input_name
      return name if name.end_with?('[]')
      return "#{name}[]"
    end

    private

    def selected_option_text(value)
      option = @options.find { |opt| option_value(opt) == value.to_s }
      return value.to_s unless option

      option_text(option)
    end

    def option_value(option)
      return option.last.to_s if option.is_a?(Array)

      option.to_s
    end

    def option_text(option)
      return option.first if option.is_a?(Array)

      option.to_s
    end
  end
end
