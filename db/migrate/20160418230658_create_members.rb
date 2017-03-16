class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.belongs_to :party, index: true
      t.string :firstname
      t.string :lastname
      t.string :img_filename
      t.integer :party_id

      t.timestamps null: false
    end
  end
end
