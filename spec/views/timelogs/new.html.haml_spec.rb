require 'rails_helper'

RSpec.describe "timelogs/new", type: :view do
  before(:each) do
    assign(:timelog, Timelog.new(
      :employee => nil,
      :claim_status => "MyString"
    ))
  end

  it "renders new timelog form" do
    render

    assert_select "form[action=?][method=?]", timelogs_path, "post" do

      assert_select "input#timelog_employee_id[name=?]", "timelog[employee_id]"

      assert_select "input#timelog_claim_status[name=?]", "timelog[claim_status]"
    end
  end
end
