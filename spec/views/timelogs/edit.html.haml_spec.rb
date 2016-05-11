require 'rails_helper'

RSpec.describe "timelogs/edit", type: :view do
  before(:each) do
    @timelog = assign(:timelog, Timelog.create!(
      :employee => nil,
      :claim_status => "MyString"
    ))
  end

  it "renders the edit timelog form" do
    render

    assert_select "form[action=?][method=?]", timelog_path(@timelog), "post" do

      assert_select "input#timelog_employee_id[name=?]", "timelog[employee_id]"

      assert_select "input#timelog_claim_status[name=?]", "timelog[claim_status]"
    end
  end
end
