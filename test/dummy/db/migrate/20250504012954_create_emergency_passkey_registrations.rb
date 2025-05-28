class CreateEmergencyPasskeyRegistrations < ActiveRecord::Migration[8.0]
  def change
    create_table :emergency_passkey_registrations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :passkey, foreign_key: true
      t.references :ip_address, foreign_key: true
      t.references :user_agent, foreign_key: true
      t.datetime :used_at

      t.timestamps
    end
  end
end
