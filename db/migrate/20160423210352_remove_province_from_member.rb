class RemoveProvinceFromMember < ActiveRecord::Migration
  def change
    remove_column :members, :province
  end
end
