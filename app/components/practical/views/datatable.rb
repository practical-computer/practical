# frozen_string_literal: true

module Practical::Views::Datatable
  extend ActiveSupport::Concern

  def sort_link_for(key:, &block)
    component = Practical::Views::Datatable::SortLinkComponent.new(
      url: sort_url_for(key: key),
      datatable_form: datatable_form,
      sort_key: key,
      options: {class: "wa-flank wa-gap-2xs"}
    )

    render(component, &block)
  end

  def inverted_sort_direction(datatable_form:, sort_key:)
    datatable_form.inverted_sort_direction_for(key: sort_key)
  end

  def merged_payload(datatable_form:, sort_key:)
    datatable_form.merged_payload(sort_key: sort_key,
                                  sort_direction: inverted_sort_direction(datatable_form: datatable_form,
                                                                          sort_key: sort_key
                                                                        )
                                 )
  end

  def pagination_component
    return Practical::Views::Navigation::PaginationComponent.new(
      pagy: pagy,
      request: request,
      i18n_key: "pagy.item_name"
    )
  end
end