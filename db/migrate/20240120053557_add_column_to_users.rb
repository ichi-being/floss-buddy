class AddColumnToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :display_name, :string , null: false
    add_column :users, :image, :string
  end
end
