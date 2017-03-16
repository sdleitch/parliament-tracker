class CreateNewsArticles < ActiveRecord::Migration
  def change
    create_table :news_articles do |t|
      t.string :title
      t.string :description
      t.string :outlet
      t.date :date

      t.timestamps null: false
    end
  end
end
