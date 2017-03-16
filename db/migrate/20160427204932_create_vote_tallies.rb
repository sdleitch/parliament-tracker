class CreateVoteTallies < ActiveRecord::Migration
  def change
    create_table :vote_tallies do |t|
      t.boolean :agreed_to
      t.integer :vote_number
      t.date :date

      t.timestamps null: false
    end
  end
end
