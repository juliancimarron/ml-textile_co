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
      log_date: Time.now.to_date,
      arrive_datetime: DateTime.parse('8:10 am'),
      leave_datetime: DateTime.parse('5:00 pm'),
      claim_arrive_datetime: DateTime.parse('8:00 am'),
      claim_leave_datetime: DateTime.parse('5:30 pm'),
      claim_status: Timelog::CLAIM_STATUS_OPT.first
    }
  end
  let(:timelog_invalid_attributes) { {employee_id: ''} }

end
