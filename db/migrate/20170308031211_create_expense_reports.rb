class CreateExpenseReports < ActiveRecord::Migration
  def change
    create_table :expense_reports do |t|
      t.date :start_date
      t.date :end_date
      t.string :quarter
      t.references :member, index: true
      t.integer :total

      t.timestamps null: false
    end
    add_foreign_key :expense_reports, :members
  end
end
