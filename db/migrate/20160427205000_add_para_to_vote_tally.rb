class AddParaToVoteTally < ActiveRecord::Migration
  def change
    add_column :vote_tallies, :para, :text
  end
end
