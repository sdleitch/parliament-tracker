class CreateParliments < ActiveRecord::Migration
  def change
    create_table :parliments do |t|
      t.integer :number
      t.date :startdate
      t.date :enddate

      t.timestamps null: false
    end
  end
end
