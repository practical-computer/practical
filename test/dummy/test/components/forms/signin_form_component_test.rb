# frozen_string_literal: true

require "test_helper"

class Forms::SigninFormComponentTest < ViewComponent::TestCase
  test "renders the signin form" do
    result = Forms::SigninFormComponent.new(
      model: User.first,
      as: :user,
      url: "auth_url",
      challenge_url: "challenge_url",
      credential_field_name: "credential_field_name"
    )

    render_inline(result)
    assert_selector("form")
  end
end
