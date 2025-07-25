module Polaris
  class FormBuilder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::OutputSafetyHelper

    attr_reader :template

    delegate :render, :pluralize, to: :template

    def errors_summary(within: :container)
      return if object.blank?
      return unless object.errors.any?

      title = I18n.t(
        "polaris.form_builder.errors_summary",
        count: object.errors.count,
        model: object.class.model_name.human.downcase
      )

      render Polaris::BannerComponent.new(
        title: title,
        status: :critical,
        within: within,
        data: {errors_summary: true}
      ) do |banner|
        [
          render(Polaris::ListComponent.new) do |list|
            object.errors.full_messages.each do |error|
              list.with_item { error.html_safe }
            end
          end,
          (template.capture { yield(banner) } if block_given?)
        ].compact.join.html_safe
      end
    end

    def error_for(method)
      return if object.blank?
      return unless object.errors.key?(method)

      raw object.errors.full_messages_for(method)&.first
    end

    def polaris_inline_error_for(method, **options, &block)
      error_message = error_for(method)
      return unless error_message

      render(Polaris::InlineErrorComponent.new(**options, &block)) do
        error_message
      end
    end

    def polaris_text_field(method, **options, &block)
      apply_error_options(options, method)

      render Polaris::TextFieldComponent.new(form: self, attribute: method, **options), &block
    end

    def polaris_select(method, **options, &block)
      apply_error_options(options, method)

      value = object&.public_send(method)
      if value.present?
        options[:selected] = value
      end
      render Polaris::SelectComponent.new(form: self, attribute: method, **options, &block)
    end

    def polaris_multi_select(method, **options, &block)
      apply_error_options(options, method)

      value = object&.public_send(method)
      if value.present?
        options[:selected] = value
      end
      render Polaris::MultiSelectComponent.new(form: self, attribute: method, **options, &block)
    end
    
    def polaris_check_box(method, **options, &block)
      apply_error_options(options, method)

      render Polaris::CheckboxComponent.new(form: self, attribute: method, **options, &block)
    end

    def polaris_radio_button(method, **options, &block)
      apply_error_options(options, method)

      render Polaris::RadioButtonComponent.new(form: self, attribute: method, **options, &block)
    end

    def polaris_dropzone(method, **options, &block)
      apply_error_options(options, method)

      render Polaris::DropzoneComponent.new(form: self, attribute: method, **options, &block)
    end

    def polaris_collection_check_boxes(method, collection, value_method, text_method, **options, &block)
      apply_error_options(options, method)

      value = object&.public_send(method)
      if value.present?
        options[:selected] = value.map { |el| el.public_send(value_method) }
      end
      input_options = options.delete(:input_options) || {}

      render Polaris::ChoiceListComponent.new(
        form: self,
        title: method.to_s.humanize,
        attribute: method,
        name: method,
        **options,
        &block
      ) do |choice|
        collection.each do |item|
          choice.with_checkbox(
            label: item.public_send(text_method),
            value: item.public_send(value_method),
            input_options: input_options
          )
        end
      end
    end

    def polaris_autocomplete(method, **options, &block)
      apply_error_options(options, method)

      render Polaris::AutocompleteComponent.new(form: self, attribute: method, name: method, **options), &block
    end

    private

    def apply_error_options(options, method)
      options[:error] ||= error_for(method) unless options.has_key?(:error)

      if options[:error_hidden] && options[:error]
        options[:error] = !!options[:error]
      end
    end
  end
end
