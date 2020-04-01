class CreateSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :sessions do |t|
      t.string :session_string
      t.integer :click_count
      t.references :team, null: false, foreign_key: true

      t.timestamps
    end
  end
end
