class Organization::Attachment < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  include Organization::AttachmentUploader::Attachment(:attachment)

  validates :organization, presence: true
  validates :user, presence: true
  validate :user_has_membership_in_organization, on: :create

  protected

  def user_has_membership_in_organization
    return if organization.blank?
    return if user.blank?
    return if OrganizationPolicy.new(organization, user: user).apply(:show?)
    errors.add(:user, :cannot_access_organization)
  end
end
