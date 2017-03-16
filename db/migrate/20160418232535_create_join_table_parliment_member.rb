class CreateJoinTableParlimentMember < ActiveRecord::Migration
  def change
    create_join_table :parliments, :members do |t|
      t.index [:parliment_id, :member_id]
      t.index [:member_id, :parliment_id]
    end
  end
end
