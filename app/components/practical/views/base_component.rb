# frozen_string_literal: true

class Practical::Views::BaseComponent < ViewComponent::Base
  include Practical::Views::ElementHelper
  delegate :safe_join, :icon_set, to: :helpers
end
