require 'rails_helper'

RSpec.feature "EmployeeWorkflows", type: :feature do

  fixtures :employees
  fixtures :timelogs
  
  it "Root redirects to sign in if not logged in" do
    visit '/'
    expect(page).to have_text 'Textile.Co'
    expect(page).to have_text 'Log in'
    expect(page).to have_css 'input[type="submit"]'
  end

  it "Root is My Timesheet and can report errors there" do  
    visit '/'  
    fill_in 'Employee ID', with: employees(:julian).employee_id
    fill_in 'Password', with: '123456'
    click_button 'Log in'
    # expect(page).to have_text 'Timesheet Review'
    # expect(page).to have_css 'th', text: 'Arrival', count: 1
    # click_link 'Report Error'
    # expect(page).to have_text 'Report Timesheet Error'
    # expect(page).to have_css 'th', text: 'Moment'
    # expect(page).to have_button 'Cancel'
    # fill_in '#claim_arrive_datetime', with: '7:00 am'
    # fill_in '#claim_leave_datetime', with: '6:00 pm'
    # click_button 'Submit'
    # expect(page).to have_text 'Timesheet Review'
    # expect(page).to have_text '7:00 am'
    # expect(page).to have_text '6:00 pm'
  end

  xit "Can go to My Profile" do
    visit '/'  
    fill_in 'Employee ID', with: employees(:julian).employee_id
    fill_in 'Password', with: '123456'
    click_button 'Log in'
    click_link 'My Profile'
    expect(page).to have_text 'Employee Profile'
    expect(page).to have_button 'Back'
  end

end
