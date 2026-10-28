class AllowUploadedImagesWithoutSourceUrls < ActiveRecord::Migration[8.1]
  def change
    change_column_null :images, :url, true
  end
end
