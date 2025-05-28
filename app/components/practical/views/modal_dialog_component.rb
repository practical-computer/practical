# frozen_string_literal: true

class Practical::Views::ModalDialogComponent < Practical::Views::BaseComponent
  renders_one :header
  attr_accessor :id, :open, :options

  def initialize(id:, open: false, options: {})
    self.open = open
    self.id = id
    self.options = options
  end

  def finalized_options
    mix({id: id, open: open, data: {ensure_modal: true}, class: 'wa-dialog-stack-patch'}, options)
  end
end
