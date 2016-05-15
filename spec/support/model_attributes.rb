RSpec.shared_context "model_attributes" do

  let(:name) { FFaker::Name }

  # Department
  let(:department_valid_attributes) { {name: 'New Department'} }
  let(:department_invalid_attributes) { {name: nil} }


 # Employee
  let(:employee_valid_attributes) do
    {
      first_name: name.first_name,
      last_name: name.last_name,
      department: Department.first
    }
  end
  let(:employee_invalid_attributes) { {first_name: ''} }


  # Timelog
  let(:timelog_valid_attributes) do
    {
      employee: Employee.first,
      log_date: Time.now.to_date - 1.day,
      arrive_sec: 9.hours + 30.minutes,
      leave_sec: 18.hours,
      claim_arrive_sec: 9.hours,
      claim_leave_sec: 18.hours + 30.minutes,
      claim_status: Timelog::CLAIM_STATUS_OPT.first
    }
  end
  let(:timelog_invalid_attributes) do
    {
      claim_arrive_sec: 18.hours,
      claim_leave_sec: 9.hours
    }
  end

  # Timesheet
  time = Time.now
  date = Date.new(time.year, time.month, 1)
  let(:timesheet_valid_attributes) do
    {
      employee: Employee.first,
      period_start_date: date,
      period_end_date: Date.new(date.year, date.month, -1),
      logged_hrs: 180,
      logged_min: 10,
      pay_date: Date.new(date.year, date.month + 1, 7)
    }
  end

end
