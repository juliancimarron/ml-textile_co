class CreateTimelogs < ActiveRecord::Migration
  def change
    create_table :timelogs do |t|
      t.references :employee, index: true, foreign_key: true
      t.date :log_date
      t.integer :arrive_sec
      t.integer :leave_sec
      t.integer :claim_arrive_sec
      t.integer :claim_leave_sec
      t.string :claim_status

      t.timestamps null: false
    end
  end
end
