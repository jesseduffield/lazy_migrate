# typed: true
class AddBookWeight < ActiveRecord::Migration[5.1]
  def up
    add_column :books, :weight, :integer
  end

  def down
    remove_column :books, :weight, :integer
  end
end
