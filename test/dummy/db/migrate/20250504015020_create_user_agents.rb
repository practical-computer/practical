class CreateUserAgents < ActiveRecord::Migration[8.0]
  def change
    create_table :user_agents do |t|
      t.string :user_agent, index: {unique: true}

      t.timestamps
    end
  end
end
