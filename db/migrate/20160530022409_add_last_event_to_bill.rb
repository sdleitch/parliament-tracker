class AddLastEventToBill < ActiveRecord::Migration
  def change
    add_column :bills, :last_event, :string
    add_column :bills, :last_event_date, :date
  end
end
