class CreateOrganizationAttachments < ActiveRecord::Migration[8.0]
  def change
    create_table :organization_attachments do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.json :attachment_data

      t.timestamps
    end
  end
end
