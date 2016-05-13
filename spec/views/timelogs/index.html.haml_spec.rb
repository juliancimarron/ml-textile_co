require 'rails_helper'

RSpec.describe "timelogs/index", type: :view do

  fixtures :employees

  describe "renders the signed in employee's timelogs" do
    let(:last_month_day) { 31 }
    let(:month) { 5 }
    let(:year) { 2016 }
    let(:employee) { employees(:john) }

    before(:example) do
      sign_in employee

      base_dt = DateTime.new year, month
      timelog_dt = base_dt

      timelog_dt = base_dt - 1.day
      (last_month_day - 1).times {
        timelog_dt += 1.day
        Timelog.create(
          employee_id: employee.id,
          log_date: timelog_dt.to_date,
          arrive_datetime: (timelog_dt + 9.hours),
          leave_datetime: (timelog_dt + 18.hours)
        )
      }

      Timesheet.create( 
        employee_id: employee.id,
        period_start_date: base_dt.to_date,
        period_end_date: (base_dt + last_month_day.days - 1.days).to_date
      )

      @timelogs = Timelog.all
      @timesheets = Timesheet.all
      @timesheet = @timesheets.last
      @timesheet_ids = [1,2,3]
      @proc_timelogs = Timelog.process_timelogs @timesheet, employee
    end

    specify { expect(render).to have_css '.top-bar', count: 1 }
    specify { expect(render).to have_css 'form', count: 1 }
    specify { expect(render).to have_css 'tbody > tr', count: last_month_day }
    specify { expect(render).to have_css 'th', text: 'Minutes' }
    specify { expect(render).to have_text @timelogs.sample[:leave] }
  end
end
