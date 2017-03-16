class CreateJoinTableNewsArticleMember < ActiveRecord::Migration
  def change
    create_join_table :news_articles, :members do |t|
      # t.index [:news_article_id, :member_id]
      # t.index [:member_id, :news_article_id]
    end
  end
end
