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

end
