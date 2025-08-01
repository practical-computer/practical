# frozen_string_literal: true

module Practical::Test::Helpers::Integration::Assertions
  def assert_error_json_contains(container_id:, element_id:, message:, type:)
    found_message = response.parsed_body.find do |error_json|
      error_json["container_id"] == container_id &&
      error_json["element_to_invalidate_id"] == element_id &&
      error_json["message"] == message &&
      error_json["type"] == type
    end

    assert_not_nil found_message, response.parsed_body
  end

  def assert_json_redirected_to(location)
    assert_equal "322", response.code
    assert_equal location, response.parsed_body["location"]
  end

  def assert_error_dom(container_id:, message:)
    assert_dom("##{container_id}", text: %r{#{message}})
  end
end