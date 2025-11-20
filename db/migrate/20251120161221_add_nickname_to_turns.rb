class AddNicknameToTurns < ActiveRecord::Migration[8.1]
  def change
    add_column :turns, :nickname, :string
  end
end
