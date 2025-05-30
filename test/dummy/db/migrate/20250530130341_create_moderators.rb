class CreateModerators < ActiveRecord::Migration[8.0]
  def change
    create_table :moderators do |t|
      t.string :email, null: false, index: {unique: true }
      t.string :webauthn_id, null: false
      t.datetime :remember_created_at
      t.text :remember_token, index: {unique: true }

      t.timestamps
    end
  end
end
