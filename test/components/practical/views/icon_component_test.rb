# frozen_string_literal: true

require "test_helper"

class Practical::Views::IconComponentTest < ViewComponent::TestCase
  test "default" do
    assert_equal(
      %(<wa-icon name="user" family="solid" fixed-width="true"></wa-icon>),
      render_inline(Practical::Views::IconComponent.new(name: :user, family: :solid)).css("wa-icon").to_html
    )
  end

  test "setting a variant" do
    assert_equal(
      %(<wa-icon name="user" family="solid" variant="thin" fixed-width="true"></wa-icon>),
      render_inline(Practical::Views::IconComponent.new(name: :user, family: :solid, variant: :thin)).css("wa-icon").to_html
    )
  end

  test "adding classes" do
    assert_equal(
      %(<wa-icon name="user" family="solid" fixed-width="true" class="current-user"></wa-icon>),
      render_inline(Practical::Views::IconComponent.new(name: :user, family: :solid, options: {class: "current-user"})).css("wa-icon").to_html
    )
  end

  test "style overrides" do
    assert_equal(
      %(<wa-icon name="user" family="solid" fixed-width="true" style="font-size: 3em; color: Tomato;"></wa-icon>),
      render_inline(Practical::Views::IconComponent.new(name: :user, family: :solid, options: {style: "font-size: 3em; color: Tomato;"})).css("wa-icon").to_html
    )
  end

  test "is JSON serializable" do
    icon = Practical::Views::IconComponent.new(name: :user, family: :solid, options: {style: "font-size: 3em; color: Tomato;"})

    expected = {
      "name" => "user",
      "family" => "solid",
      "variant" => nil,
      "fixed_width" => true,
      "label" => nil,
      "options" => {"style" => "font-size: 3em; color: Tomato;"}
    }

    assert_equal expected, icon.as_json
  end
end
