# frozen_string_literal: true

class CreateIPAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :ip_addresses do |t|
      t.string :address, index: {unique: true}

      t.timestamps
    end
  end
end
