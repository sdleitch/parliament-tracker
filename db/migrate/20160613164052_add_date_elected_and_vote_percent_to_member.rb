class AddDateElectedAndVotePercentToMember < ActiveRecord::Migration
  def change
    add_column :members, :date_elected, :date
    add_column :members, :vote_percent, :integer
  end
end
