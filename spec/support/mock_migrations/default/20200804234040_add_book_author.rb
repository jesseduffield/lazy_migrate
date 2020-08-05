# typed: false
class AddBookAuthor < ActiveRecord::Migration[5.1]
  def up
    add_column :books, :author, :string
  end

  def down
    remove_column :books, :author, :string
  end
end
