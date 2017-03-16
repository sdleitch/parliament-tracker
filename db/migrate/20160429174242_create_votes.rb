class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.references :member, index: true
      t.references :vote_tally, index: true

      t.timestamps null: false
    end
    add_foreign_key :votes, :members
    add_foreign_key :votes, :vote_tallies
  end
end
