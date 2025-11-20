class CreateTurns < ActiveRecord::Migration[8.1]
  def change
    create_table :turns do |t|
      t.references :day, null: false, foreign_key: true
      t.integer :turn_index
      t.text :prompt

      t.timestamps
    end
  end
end
