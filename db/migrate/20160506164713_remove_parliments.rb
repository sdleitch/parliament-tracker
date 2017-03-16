class RemoveParliments < ActiveRecord::Migration
  def change
    drop_table :parliments
  end
end
