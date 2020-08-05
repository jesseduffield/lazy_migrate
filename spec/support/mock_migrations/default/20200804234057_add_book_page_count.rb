class AddBookPageCount < ActiveRecord::Migration[5.2]
  def up
    add_column :books, :page_count, :integer
  end

  def down
    remove_column :books, :page_count, :integer
  end
end
