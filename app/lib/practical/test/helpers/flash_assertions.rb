# frozen_string_literal: true

module Practical::Test::Helpers::FlashAssertions
  def assert_flash_message(type:, message:, icon_name:)
    assert_equal message, flash[type][:message], flash
    assert_includes flash[type][:icon].name.to_s, icon_name, flash
  end
end