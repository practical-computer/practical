# frozen_string_literal: true

class Practical::Views::Navigation::Pagination::GotoFormComponent < Practical::Views::BaseComponent
  include Pagy::Frontend
  attr_accessor :pagy, :dialog_id, :page_detail_text

  URIParts = Data.define(:uri, :params)

  def initialize(pagy:, dialog_id:, page_detail_text:)
    self.pagy = pagy
    self.dialog_id = dialog_id
    self.page_detail_text = page_detail_text
  end

  def uri_parts
    uri = URI.parse(pagy_url_for(pagy, nil))
    params = Rack::Utils.parse_query(uri.query)
    params.delete("page")
    uri.query = ""

    URIParts.new(uri: uri, params: params)
  end

  def hidden_field_for_goto_form(key:, value:)
    case value
    when Array
      value.each do |x|
        helpers.hidden_field_tag key, x
      end
    else
      helpers.hidden_field_tag key, value
    end
  end
end
