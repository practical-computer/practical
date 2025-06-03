# frozen_string_literal: true

class Practical::RelationBuilders::Base
  attr_accessor :payload, :relation

  def initialize(payload:, relation:)
    self.payload = payload
    self.relation = relation
  end

  def applied_relation
    scope = apply_filtering(scope: relation)
    scope = apply_ordering(scope: scope)

    return scope
  end

  def apply_filtering(scope:)
    raise NotImplementedError
  end

  def apply_ordering(scope:)
    scope = first_order_sorting(scope: scope)
    scope = second_order_sorting(scope: scope)
    return scope
  end

  def first_order_sorting(scope:)
    raise NotImplementedError
  end

  def second_order_sorting(scope:)
    raise NotImplementedError
  end
end