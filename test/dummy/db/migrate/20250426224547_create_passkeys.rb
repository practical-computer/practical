class CreatePasskeys < ActiveRecord::Migration[8.0]
  def change
    create_table :passkeys do |t|
      t.references :user, null: false, foreign_key: true
      t.string :label, null: false
      t.string :external_id, null: false, index: {unique: true}
      t.string :public_key, null: false, index: {unique: true}
      t.integer :sign_count
      t.datetime :last_used_at

      t.timestamps
    end
  end
end
