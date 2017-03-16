class AddMemberToVoteTally < ActiveRecord::Migration
  def change
    add_reference :vote_tallies, :member, index: true
    add_foreign_key :vote_tallies, :members
  end
end
