class DropNewsArticles < ActiveRecord::Migration
  def change
    drop_table :news_articles
    drop_table :members_news_articles
  end
end
