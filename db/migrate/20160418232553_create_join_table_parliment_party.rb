class CreateJoinTableParlimentParty < ActiveRecord::Migration
  def change
    create_join_table :parliments, :parties do |t|
      t.index [:parliment_id, :party_id]
      t.index [:party_id, :parliment_id]
    end
  end
end
