# require 'rails_helper'

RSpec.feature "EmployeeWorkflows", type: :feature do

  fixtures :employees
  fixtures :timelogs

  let(:reg_emplyee) { employees(:john) }
  let(:reg_employee_login) do
    visit '/'  
    fill_in 'Employee ID', with: reg_emplyee.employee_id
    fill_in 'Password', with: '123456'
    click_button 'Log in'
  end
  
  it "Root redirects to sign in if not logged in" do
    visit '/'
    expect(page).to have_text 'Textile.Co'
    fill_in 'Employee ID', with: reg_emplyee.employee_id
    fill_in 'Password', with: '123456'
    expect(page).to have_button 'Log in'
  end

  it "Root is My Timesheets and can report errors" do  
    reg_employee_login
    expect(page).to have_text 'Timesheet Review'
    expect(page).to have_css 'th', text: 'Arrival', count: 1
    expect(page).to have_link 'Edit Report'
    click_link 'Edit Report'
    expect(page).to have_text 'Report Timesheet Error'
    expect(page).to have_css 'th', text: 'Moment'
    claimed_time = '8:45 AM'
    fill_in 'timelog_claim_arrive_sec', with: '8:45 am'
    click_button 'Submit'
    expect(page).to have_text 'Reported Timesheet Error'
    expect(page).to have_text 'Report successfully submitted'
    expect(page).to have_text 'Claimed by Employee'
    expect(page).to have_text claimed_time
    click_link 'Timesheets'
    expect(page).to have_text 'Timesheet Review'
    expect(page).to have_text claimed_time
  end

  it "Can go to My Profile" do
    reg_employee_login
    click_link 'My Profile'
    expect(page).to have_text 'Employee Profile'
    expect(page).to have_link 'Back'
    click_link 'Back'
    expect(page).to have_text 'Timesheet Review'
  end

  it "does not see admin area" do
    reg_employee_login
    expect(page).not_to have_css '.admin-menu'
    expect(page).not_to have_link 'Assistance'
    expect(page).not_to have_link 'Timesheet Errors'
  end

  it "Can sign out" do
    reg_employee_login
    click_link 'Sign Out'
    expect(page).to have_text 'Log in'
  end

end
