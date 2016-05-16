require 'rails_helper'

RSpec.describe "employees/index", type: :view do
  # before(:each) do
  #   assign(:employees, [
  #     Employee.create!(
  #       :employee_id => "Employee",
  #       :first_name => "First Name",
  #       :last_name => "Last Name",
  #       :department => nil,
  #       :admin => false
  #     ),
  #     Employee.create!(
  #       :employee_id => "Employee",
  #       :first_name => "First Name",
  #       :last_name => "Last Name",
  #       :department => nil,
  #       :admin => false
  #     )
  #   ])
  # end

  # it "renders a list of employees" do
  #   render
  #   assert_select "tr>td", :text => "Employee".to_s, :count => 2
  #   assert_select "tr>td", :text => "First Name".to_s, :count => 2
  #   assert_select "tr>td", :text => "Last Name".to_s, :count => 2
  #   assert_select "tr>td", :text => nil.to_s, :count => 2
  #   assert_select "tr>td", :text => false.to_s, :count => 2
  # end
end
