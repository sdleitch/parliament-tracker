class AddMemberIdToBills < ActiveRecord::Migration
  def change
    add_column :bills, :member_id, :integer
  end
end
