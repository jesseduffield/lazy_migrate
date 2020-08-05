# typed: true
class AddBookRating < ActiveRecord::Migration[5.1]
  def up
    add_column :books, :rating, :integer
  end

  def down
    remove_column :books, :rating, :integer
  end
end
