class RemoveParlimentIndexTables < ActiveRecord::Migration
  def change
    drop_table :members_parliments
    drop_table :parliments_parties
  end
end
