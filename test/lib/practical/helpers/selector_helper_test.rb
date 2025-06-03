# frozen_string_literal: true

require "test_helper"

class Practical::Helpers::SelectorHelperTest < ActiveSupport::TestCase
  class TestClass
    extend Practical::Helpers::SelectorHelper
  end

  class TestModel
    include GlobalID::Identification

    def id
      3
    end
  end

  test "id_selector" do
    assert_equal "#test1234", TestClass.id_selector("test1234")
    assert_equal "#1234", TestClass.id_selector(1234)

    record = TestModel.new

    assert_equal "##{record.to_gid_param}", TestClass.id_selector(record.to_gid)
    assert_equal "##{record.to_gid_param}", TestClass.id_selector(record.to_gid_param)
  end
end