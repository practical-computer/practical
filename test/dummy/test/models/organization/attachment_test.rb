require "test_helper"

class Organization::AttachmentTest < ActiveSupport::TestCase
  include Practical::Test::Helpers::Shrine::TestData
  include Practical::Test::Shared::Attachment::Model::Attachment

  def uploader_class
    Organization::AttachmentUploader
  end

  def model_class
    Organization::Attachment
  end

  def user_reflection_name
    :user
  end

  def other_user
    users.organization_3_owner
  end

  def regular_user_in_organization
    users.works_at_org_1_and_2
  end

  def admin_user_in_organization
    users.organization_1_department_head
  end

  def assert_saved_attachment(organization:, user:, file:, file_size:, file_name:, mime_type:)
    assert_difference "Organization::Attachment.count", +1 do
      attachment = organization.attachments.create!(user: user, attachment: file)

      assert_equal true, attachment.persisted?

      assert_equal organization, attachment.organization
      assert_equal file_size, attachment.attachment.metadata["size"]
      assert_equal file_name, attachment.attachment.metadata["filename"]
      assert_equal mime_type, attachment.attachment.metadata["mime_type"]
    end
  end

  def valid_new_attachment
    organizations.organization_1.attachments.build(
      attachment: plaintext_file,
      user: users.organization_1_owner
    )
  end

  def build_new_attachment(file:)
    user = users.organization_1_owner
    organization = organizations.organization_1

    organization.attachments.build(user: user, attachment: file)
  end

  def create_saved_attachment(file:)
    user = users.organization_1_owner
    organization = organizations.organization_1
    attachment = nil

    assert_difference "Organization::Attachment.count", +1 do
      attachment = organization.attachments.create!(user: user, attachment: file)

      assert_equal true, attachment.persisted?
      assert_equal organization, attachment.organization

      yield(attachment) if block_given?
    end
  end
end
