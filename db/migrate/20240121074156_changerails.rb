class Changerails < ActiveRecord::Migration[7.0]
  def change
    change_column_null :floss_records, :record_date, true
  end
end
