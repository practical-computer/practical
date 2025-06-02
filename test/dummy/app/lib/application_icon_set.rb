# frozen_string_literal: true

class ApplicationIconSet < Practical::Views::IconSet
  def self.membership_type_icon(membership_type:)
    case membership_type.to_sym
    when :staff
      badge_icon
    when :organization_manager
      organization_manager_icon
    end
  end
end