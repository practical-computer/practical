# frozen_string_literal: true

class SendEmergencyPasskeyRegistrationService
  attr_accessor :user, :ip_address, :user_agent, :emergency_registration

  def initialize(email:, ip_address:, user_agent:)
    self.user = User.find_by!(email: email)

    if ip_address.present?
      self.ip_address = IPAddress.upsert_address(address: ip_address)
    end

    if user_agent.present?
      self.user_agent = UserAgent.upsert_user_agent(user_agent: user_agent)
    end
  end

  def run!
    self.emergency_registration = self.user.emergency_passkey_registrations.create!(
      user_agent: self.user_agent,
      ip_address: self.ip_address,
    )

    EmergencyPasskeyRegistrationMailer.emergency_registration_request(
      emergency_passkey_registration: emergency_registration
    ).deliver_later
  rescue ArgumentError => e
    puts e.backtrace
    raise e
  end
end
