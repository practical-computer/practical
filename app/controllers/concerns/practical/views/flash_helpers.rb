# frozen_string_literal: true

module Practical::Views::FlashHelpers
  extend ActiveSupport::Concern

  included do
    add_flash_types :success
  end

  def flash_message_with_icon(message:, icon:)
    {message: message, icon: icon}
  end

  def flash_notice_with_icon(message:, icon: default_notice_icon)
    flash_message_with_icon(message: message, icon: icon)
  end

  def flash_alert_with_icon(message:, icon: default_alert_icon)
    flash_message_with_icon(message: message, icon: icon)
  end

  def flash_success_with_icon(message:, icon: default_success_icon)
    flash_message_with_icon(message: message, icon: icon)
  end

  def default_notice_icon
    return helpers.icon_set.info_icon
  end

  def default_alert_icon
    return helpers.icon_set.alert_icon
  end

  def default_success_icon
    return helpers.icon_set.success_icon
  end
end
