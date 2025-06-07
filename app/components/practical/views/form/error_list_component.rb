# frozen_string_literal: true

class Practical::Views::Form::ErrorListComponent < Practical::Views::BaseComponent
  attr_reader :errors

  def initialize(errors:)
    @errors = errors
  end

  def call
    tag.ul {
      safe_join(errors.map{|error| render Practical::Views::Form::ErrorListItemComponent.new(error: error) })
    }
  end
end
