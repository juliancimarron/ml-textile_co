class CreateTimesheets < ActiveRecord::Migration
  def change
    create_table :timesheets do |t|
      t.references :employee, index: true, foreign_key: true
      t.date :period_start_date
      t.date :period_end_date
      t.integer :logged_hrs
      t.integer :logged_min
      t.date :pay_date
      t.boolean :approved

      t.timestamps null: false
    end
  end
end
