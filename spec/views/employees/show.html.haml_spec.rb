require 'rails_helper'

RSpec.describe "employees/show", type: :view do
  before(:each) do
    @employee = assign(:employee, Employee.create!(
      :employee_id => "Employee",
      :first_name => "First Name",
      :last_name => "Last Name",
      :department => nil,
      :admin => false
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Employee/)
    expect(rendered).to match(/First Name/)
    expect(rendered).to match(/Last Name/)
    expect(rendered).to match(//)
    expect(rendered).to match(/false/)
  end
end
