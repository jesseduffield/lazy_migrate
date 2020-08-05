class AddBookRating < ActiveRecord::Migration[5.2]
  def up
    add_column :books, :rating, :integer
  end

  def down
    remove_column :books, :rating, :integer
  end
end
