# frozen_string_literal: true

class CreateMembershipInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :membership_invitations do |t|
      t.integer :membership_type, limit: 1, null: false
      t.boolean :visible, null: false, default: true
      t.string :email, null: false, index: true
      t.references :organization, null: false, foreign_key: true
      t.references :membership, null: true, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.references :sender, null: true, foreign_key: { to_table: :users }

      t.datetime :last_sent_at
      t.timestamps
    end
  end
end
