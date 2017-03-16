class AddParliamentNumberToBills < ActiveRecord::Migration
  def change
    add_column :bills, :parliament_number, :integer
  end
end
