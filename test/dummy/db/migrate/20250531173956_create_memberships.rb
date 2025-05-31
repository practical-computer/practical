# frozen_string_literal: true

class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships do |t|
      t.integer :state, limit: 2, null: false
      t.datetime :accepted_at
      t.integer :membership_type, limit: 2, null: false
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.index [:user_id, :organization_id], unique: true
      t.timestamps
    end
  end
end
