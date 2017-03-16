class AddFednumToElectoralDistricts < ActiveRecord::Migration
  def change
    add_column :electoral_districts, :fednum, :integer
  end
end
