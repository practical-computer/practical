# frozen_string_literal: true

class ApplicationComponent < Practical::Views::BaseComponent
  delegate :icon_text, to: :helpers
end
