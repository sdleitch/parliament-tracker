class RemoveTypeFromBill < ActiveRecord::Migration
  def change
    remove_column :bills, :type
    add_column :bills, :bill_type, :string
  end
end
