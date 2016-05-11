RSpec.shared_context "model_attributes" do

  let(:name) { FFaker::Name }

  # Department
  let(:department_valid_attributes) { {name: 'New Department'} }
  let(:department_invalid_attributes) { {name: nil} }

end
