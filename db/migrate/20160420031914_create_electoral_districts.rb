class CreateElectoralDistricts < ActiveRecord::Migration
  def change
    create_table :electoral_districts do |t|
      t.string :name
      t.text :geo

      t.timestamps null: false
    end
  end
end
