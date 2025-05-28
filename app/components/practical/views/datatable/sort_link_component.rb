# frozen_string_literal: true

class Practical::Views::Datatable::SortLinkComponent < Practical::Views::BaseComponent
  attr_accessor :url, :datatable_form, :sort_key, :options

  def initialize(url:, datatable_form:, sort_key:, options: {})
    self.url = url
    self.datatable_form = datatable_form
    self.sort_key = sort_key
    self.options = options
  end

  def call
    tag.a(**mix({href: url}, options)) {
      safe_join([
        render(icon),
        content
      ])
    }
  end

  def icon
    case sort_direction
    when "desc"
      return icon_set.descending_icon
    when "asc"
      return icon_set.ascending_icon
    else
      return icon_set.sort_icon
    end
  end

  def sort_direction
    datatable_form.sort_direction_for(key: sort_key)
  end

  def self.inverted_sort_direction(datatable_form:, sort_key:)
    datatable_form.inverted_sort_direction_for(key: sort_key)
  end

  def self.merged_payload(datatable_form:, sort_key:)
    datatable_form.merged_payload(sort_key: sort_key,
                                  sort_direction: inverted_sort_direction(datatable_form: datatable_form,
                                                                          sort_key: sort_key
                                                                        )
                                 )
  end
end
