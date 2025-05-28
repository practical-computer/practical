# frozen_string_literal: true

class Practical::Views::Datatable::FilterSectionComponent < Practical::Views::BaseComponent
  renders_one :open_filters_button
  renders_many :applied_filters,  "AppliedFilterComponent"

  class Practical::Views::Datatable::FilterSectionComponent::AppliedFilterComponent < Practical::Views::BaseComponent
    renders_one :title

    def call
      tag.section(class: "wa-stack wa-gap-0") do
        safe_join([
          tag.strong(title),
          content
        ])
      end
    end
  end
end
