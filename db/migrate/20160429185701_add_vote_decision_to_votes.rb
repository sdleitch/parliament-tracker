class AddVoteDecisionToVotes < ActiveRecord::Migration
  def change
    add_column :votes, :vote_decision, :boolean
  end
end
