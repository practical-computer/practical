# frozen_string_literal: true

module Practical::Helpers::SelectorHelper
  def id_selector(text)
    text = text.to_param if text.is_a?(GlobalID)
    "##{text}"
  end
end