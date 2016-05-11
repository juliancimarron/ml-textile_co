class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string :employee_id
      t.string :first_name
      t.string :last_name
      t.references :department, index: true, foreign_key: true
      t.boolean :admin

      t.timestamps null: false
    end
  end
end
