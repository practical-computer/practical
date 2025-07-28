# frozen_string_literal: true

class Practical::Views::FlashMessagesComponent < Practical::Views::BaseComponent
  def call
    messages = toasts
    tag.aside(class: 'notification-messages wa-stack') do
      safe_join(messages) if messages.present?
    end
  end

  def toasts
    [
      alert_toast,
      notice_toast,
      success_toast,
    ].compact
  end

  def success_toast
    render_toast(
      color_variant: :success,
      data: helpers.flash[:success],
      default_icon: icon_set.success_icon
    )
  end

  def notice_toast
    render_toast(
      color_variant: :neutral,
      data: helpers.flash[:notice],
      default_icon: icon_set.info_icon
    )
  end

  def alert_toast
    render_toast(
      color_variant: :warning,
      data: helpers.flash[:alert],
      default_icon: icon_set.alert_icon
    )
  end

  def render_toast(color_variant:, data:, default_icon:)
    return nil if data.nil?

    case data
    when String
      message = data
      icon = default_icon
    when Hash
      data = data.with_indifferent_access
      message = data[:message]
      icon = data[:icon]
    end

    component = Practical::Views::ToastComponent.new(color_variant: color_variant)

    render component do |component|
      if icon.present? && icon.is_a?(Hash)
        icon = Practical::Views::IconComponent.new(**icon.to_h.symbolize_keys)
        component.with_icon do
          render icon
        end
      end

      message
    end
  end
end
