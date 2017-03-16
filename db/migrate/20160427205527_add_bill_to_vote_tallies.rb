class AddBillToVoteTallies < ActiveRecord::Migration
  def change
    add_reference :vote_tallies, :bill, index: true
    add_foreign_key :vote_tallies, :bills
  end
end
