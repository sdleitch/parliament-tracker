class AddMembersBudgetAndResourcesProvidedByTheHouseToExpenseReports < ActiveRecord::Migration
  def change
    add_column :expense_reports, :members_budget, :integer
    add_column :expense_reports, :house_resources, :integer
  end
end
