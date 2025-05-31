# frozen_string_literal: true

class AddRememberTokenToUsers < ActiveRecord::Migration[8.0]
  def change
    change_table :users do |t|
      t.text :remember_token, index: {unique: true}
    end
  end
end
