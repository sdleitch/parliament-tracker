class AddProvinceToElectoralDistrict < ActiveRecord::Migration
  def change
    add_column :electoral_districts, :province, :string
  end
end
