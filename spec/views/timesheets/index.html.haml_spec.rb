require 'rails_helper'

RSpec.describe "timesheets/index", type: :view do
  # before(:each) do
  #   assign(:timesheets, [
  #     Timesheet.create!(
  #       :employee => nil,
  #       :logged_hrs => 1,
  #       :logged_min => 2,
  #       :approved => false
  #     ),
  #     Timesheet.create!(
  #       :employee => nil,
  #       :logged_hrs => 1,
  #       :logged_min => 2,
  #       :approved => false
  #     )
  #   ])
  # end

  # it "renders a list of timesheets" do
  #   render
  #   assert_select "tr>td", :text => nil.to_s, :count => 2
  #   assert_select "tr>td", :text => 1.to_s, :count => 2
  #   assert_select "tr>td", :text => 2.to_s, :count => 2
  #   assert_select "tr>td", :text => false.to_s, :count => 2
  # end
end
