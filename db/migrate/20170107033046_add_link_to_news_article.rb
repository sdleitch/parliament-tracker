class AddLinkToNewsArticle < ActiveRecord::Migration
  def change
    add_column :news_articles, :link, :string
  end
end
