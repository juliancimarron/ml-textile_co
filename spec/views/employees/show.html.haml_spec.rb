require 'rails_helper'

RSpec.describe "employees/show", type: :view do

  fixtures :employees
  fixtures :departments

  before(:each) do
    sign_in employees(:john)
    @employee = employees(:john)
  end

  it "renders main elements" do
    render

    expect(rendered).to have_text 'First Name'
    expect(rendered).to have_text @employee.first_name.titlecase
    expect(rendered).to have_link 'Back'
  end
end
