class AddLatestPublicationToBill < ActiveRecord::Migration
  def change
    add_column :bills, :latest_publication, :integer
  end
end
