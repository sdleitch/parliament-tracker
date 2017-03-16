class AddElectoralDistrictToMembers < ActiveRecord::Migration
  def change
    add_reference :members, :electoral_district, index: true
    add_foreign_key :members, :electoral_districts
  end
end
