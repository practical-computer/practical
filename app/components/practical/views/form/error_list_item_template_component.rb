# frozen_string_literal: true

class Practical::Views::Form::ErrorListItemTemplateComponent < Practical::Views::BaseComponent
  def call
    tag.template(id: 'pf-error-list-item-template') {
      render Practical::Views::Form::ErrorListItemComponent.new(error: ActiveModel::Error.new(nil, nil, nil))
    }
  end
end
