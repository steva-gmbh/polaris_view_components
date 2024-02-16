module Polaris
  class TabsComponent < Polaris::Component
    renders_many :tabs, Polaris::Tabs::TabComponent
    renders_one :tabs_header, Polaris::Tabs::TabsHeader

    def initialize(fitted: false, wrapper_arguments: {}, **system_arguments)
      @fitted = fitted
      @wrapper_arguments = wrapper_arguments
      @system_arguments = system_arguments
      @tabs_header = system_arguments[:tabs_header]
      system_arguments[:tabs_header] = nil
    end

    def wrapper_arguments
      @wrapper_arguments.tap do |opts|
        opts[:tag] = "div"
        opts[:classes] = class_names(
          @wrapper_arguments[:classes],
          "Polaris-LegacyTabs__Wrapper"
        )
      end
    end

    def system_arguments
      @system_arguments.tap do |opts|
        opts[:tag] = "ul"
        opts[:role] = "tablist"
        opts[:classes] = class_names(
          @system_arguments[:classes],
          "Polaris-LegacyTabs",
          "Polaris-LegacyTabs--fitted": @fitted
        )
      end
    end

    def renders?
      tabs.present?
    end

    def render_tabs_header?
      tabs_header.present? || @tabs_header.present?
    end
  end
end
