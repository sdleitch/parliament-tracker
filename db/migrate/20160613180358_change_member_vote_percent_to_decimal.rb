class ChangeMemberVotePercentToDecimal < ActiveRecord::Migration
  def change
    change_column :members, :vote_percent, :decimal
  end
end
