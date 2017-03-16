class IndexMembersOnBills < ActiveRecord::Migration
  def change
    remove_column :bills, :member_id

    add_reference :bills, :member, index: true
    add_foreign_key :bills, :member
  end
end
