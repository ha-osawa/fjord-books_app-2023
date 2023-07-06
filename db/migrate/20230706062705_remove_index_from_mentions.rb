class RemoveIndexFromMentions < ActiveRecord::Migration[7.0]
  def change
    remove_index :mentions, name: :index_mentions_on_mentioning_report_id
  end
end
