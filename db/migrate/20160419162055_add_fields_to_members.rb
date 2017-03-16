class AddFieldsToMembers < ActiveRecord::Migration
  def change
    add_column :members, :email, :string
    add_column :members, :website, :string
    add_column :members, :province, :string
  end
end
