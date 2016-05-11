require 'rails_helper'

RSpec.xdescribe "employees/new", type: :view do
  before(:each) do
    assign(:employee, Employee.new(
      :employee_id => "MyString",
      :first_name => "MyString",
      :last_name => "MyString",
      :department => nil,
      :admin => false
    ))
  end

  it "renders new employee form" do
    render

    assert_select "form[action=?][method=?]", employees_path, "post" do

      assert_select "input#employee_employee_id[name=?]", "employee[employee_id]"

      assert_select "input#employee_first_name[name=?]", "employee[first_name]"

      assert_select "input#employee_last_name[name=?]", "employee[last_name]"

      assert_select "input#employee_department_id[name=?]", "employee[department_id]"

      assert_select "input#employee_admin[name=?]", "employee[admin]"
    end
  end
end
