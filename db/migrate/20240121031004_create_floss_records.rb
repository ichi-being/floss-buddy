class CreateFlossRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :floss_records do |t|
      t.references :user, null: false, foreign_key: true
      t.date :record_date, null: false
      t.integer :consecutive_count, default: 0

      t.timestamps
    end

    add_index :floss_records, [:user_id, :record_date], unique: true
  end
end
