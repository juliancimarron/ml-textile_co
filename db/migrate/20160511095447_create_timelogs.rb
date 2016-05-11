class CreateTimelogs < ActiveRecord::Migration
  def change
    create_table :timelogs do |t|
      t.references :employee, index: true, foreign_key: true
      t.date :log_date
      t.datetime :arrive_datetime
      t.datetime :leave_datetime
      t.datetime :claim_arrive_datetime
      t.datetime :claim_leave_datetime
      t.string :claim_status

      t.timestamps null: false
    end
  end
end
