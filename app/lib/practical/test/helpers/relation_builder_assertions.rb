# frozen_string_literal: true

module Practical::Test::Helpers::RelationBuilderAssertions
  def assert_relation_ordering_matches(expected:, relation:, instance:)
    assert_not_equal expected, relation
    assert_sql_transformation(expected: expected, actual: instance.apply_ordering(scope: relation))
  end

  def assert_relation_filtering_matches(expected:, relation:, instance:)
    assert_not_equal expected, relation
    assert_sql_transformation(expected: expected, actual: instance.apply_filtering(scope: relation))
  end

  def assert_sql_transformation(expected:, actual:)
    message = {expected_sql: expected.to_sql, actual_sql: actual.to_sql}
    assert_equal expected, actual, message
  end
end