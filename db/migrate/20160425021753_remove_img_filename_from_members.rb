class RemoveImgFilenameFromMembers < ActiveRecord::Migration
  def change
    remove_column :members, :img_filename
    add_attachment :members, :headshot
  end
end
