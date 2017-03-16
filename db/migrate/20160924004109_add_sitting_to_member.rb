class AddSittingToMember < ActiveRecord::Migration
  def change
    add_column :members, :sitting, :boolean, default: true
  end
end
