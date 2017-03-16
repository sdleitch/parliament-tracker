class CreateBills < ActiveRecord::Migration
  def change
    create_table :bills do |t|
      t.date :date_introduced
      t.string :prefix
      t.integer :number
      t.string :title_long
      t.string :title_short
      t.string :type

      t.timestamps null: false
    end
  end
end
