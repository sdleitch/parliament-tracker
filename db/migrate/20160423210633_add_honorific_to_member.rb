class AddHonorificToMember < ActiveRecord::Migration
  def change
    add_column :members, :honorific, :string
  end
end
