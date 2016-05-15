require 'rails_helper'
require 'support/model_attributes'
require 'support/shared_context'

RSpec.describe TimelogsController, type: :controller do
  include_context 'model_attributes'
  include_context 'create_timelogs_timesheets'

  fixtures :timelogs
  fixtures :timesheets
  fixtures :employees

  let(:valid_timelog) { timelogs(:john) }
  let(:reg_employee) { employees(:john) }

  before(:example) { sign_in employees(:john) } 

  context 'authorization' do 
    it "redirects to sign in if user not logged in" do
      sign_out employees(:julian)
      get :index
      expect(response).to redirect_to new_employee_session_path
    end
  end

  describe "GET #index" do
    let(:employee_timesheets) { Timesheet.where(employee: reg_employee) }

    before(:example) do
      sign_in reg_employee
      controller.instance_variable_set(:@timesheets, employee_timesheets)
    end

    it "assigns employee's timelogs by pay period to @timesheets" do
      get :index
      expect( assigns(:timesheets).first ).to be_a(Timesheet)
      expect( assigns(:timesheets).count ).to eq employee_timesheets.count
      expect( assigns(:timesheet_ids).count ).to eq employee_timesheets.count
    end

    it "assigns timesheet as @timesheet" do
      get :index
      expect( assigns(:timesheet) ).to be_a(Timesheet)
    end

    it "assigns timesheet id's as @timesheet_ids" do
      get :index
      expect( assigns(:timesheet_ids).count ).to eq employee_timesheets.count
    end

    it "assigns processed timelogs as @proc_timelogs" do
      get :index
      expect( assigns(:proc_timelogs).count ).to eq employee_timesheets.count
    end
  end

  # describe "GET #show" do
  #   it "assigns the requested timelog as @timelog" do
  #     get :show, {:id => valid_timelog.id}
  #     expect(assigns(:timelog)).to eq(valid_timelog)
  #   end
  # end

  # describe "GET #new" do
  #   it "" do
  #     get :new
  #   end
  # end

  describe "GET #edit" do
    it "assigns the requested timelog as @timelog" do
      get :edit, {:id => valid_timelog.id}
      expect(assigns(:timelog)).to eq(valid_timelog)
    end

    it "assigns the corresponding timesheet as @timesheet" do
      get :edit, {:id => valid_timelog.id}
      expect(assigns(:timesheet).employee).to eq reg_employee
    end
  end

  # describe "POST #create" do
  #   context "with valid params" do
  #     it "creates a new Timelog" do
  #       expect {
  #         post :create, {:timelog => valid_attributes}
  #       }.to change(Timelog, :count).by(1)
  #     end

  #     it "assigns a newly created timelog as @timelog" do
  #       post :create, {:timelog => valid_attributes}
  #       expect(assigns(:timelog)).to be_a(Timelog)
  #       expect(assigns(:timelog)).to be_persisted
  #     end

  #     it "redirects to the created timelog" do
  #       post :create, {:timelog => valid_attributes}
  #       expect(response).to redirect_to(Timelog.last)
  #     end
  #   end

  #   context "with invalid params" do
  #     it "assigns a newly created but unsaved timelog as @timelog" do
  #       post :create, {:timelog => invalid_attributes}
  #       expect(assigns(:timelog)).to be_a_new(Timelog)
  #     end

  #     it "re-renders the 'new' template" do
  #       post :create, {:timelog => invalid_attributes}
  #       expect(response).to render_template("new")
  #     end
  #   end
  # end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { {claim_arrive_sec: '6:00 am'} }

      it "updates the requested timelog" do
        date = '2016-05-01'
        dt_base = DateTime.parse date
        dt_time = DateTime.parse("#{date} #{new_attributes[:claim_arrive_sec]}")
        test_sec = dt_time.to_i - dt_base.to_i

        put :update, {:id => valid_timelog.id, :timelog => new_attributes}
        valid_timelog.reload
        expect(valid_timelog.claim_arrive_sec).to eq test_sec
      end

      it "assigns the requested timelog as @timelog" do
        put :update, {:id => valid_timelog.id, :timelog => timelog_valid_attributes}
        expect(assigns(:timelog)).to eq(valid_timelog)
      end

      it "sets claim_status = 'pending'" do
        valid_timelog.claim_status = nil
        put :update, {:id => valid_timelog.id, :timelog => new_attributes}
        valid_timelog.reload
        expect(valid_timelog.claim_status).to eq 'pending'
      end

      it "redirects to the timelog" do
        put :update, {:id => valid_timelog.id, :timelog => timelog_valid_attributes}
        expect(response).to redirect_to( timelog_path(valid_timelog.id) )
      end
    end

    context "with invalid params" do
      let(:update_invalid_attributes) do
        {
          claim_arrive_sec: '5:00 pm',
          claim_leave_sec: '9:00 am'
        }
      end

      it "assigns the timelog as @timelog" do
        put :update, {:id => valid_timelog.id, :timelog => update_invalid_attributes}
        expect(assigns(:timelog)).to eq(valid_timelog)
      end

      it "re-renders the 'edit' template" do
        put :update, {:id => valid_timelog.id, :timelog => update_invalid_attributes}
        expect(response).to render_template("edit")
      end
    end
  end

  # describe "DELETE #destroy" do
  #   it "destroys the requested timelog" do
  #     timelog = Timelog.create! valid_attributes
  #     expect {
  #       delete :destroy, {:id => timelog.id}
  #     }.to change(Timelog, :count).by(-1)
  #   end

  #   it "redirects to the timelogs list" do
  #     timelog = Timelog.create! valid_attributes
  #     delete :destroy, {:id => timelog.id}
  #     expect(response).to redirect_to(timelogs_url)
  #   end
  # end

  describe "GET #assistance" do
    let(:start_date) { Date.new 2016, 5, 1 }
    let(:end_date) { Date.new 2016, 5, 31 }
    let(:arrival) { 9.hours }
    let(:departure) { 18.hours }

    let(:report_params) do
      {
        type: 'tardies',
        start_date: start_date,
        end_date: end_date,
        sort_by: 'date'
      }
    end

    before(:example) do
      Employee.delete_all
      Timelog.delete_all
      FactoryGirl.create_list(:employee, 2)
      sign_out employees(:john)
      sign_in Employee.all.sample
    end

    context 'Tardies Report' do 
      let(:days_late) { 7 }
      before(:example) do
        Employee.all.each {|employee| 
          late = days_late
          date = start_date
          while date <= end_date
            offset = late > 0 ? + 1.hour : 0
            Timelog.create(
              employee: employee,
              log_date: date,
              arrive_sec: arrival + offset,
              leave_sec: departure
            )
            late -= 1
            date += 1.day
          end
        }
      end

      it "assigns the requested timelogs as @timelogs" do
        employee = controller.current_employee        
        get :assistance, report_params
        expect(assigns(:timelogs).count).to eq(days_late * Employee.count)
      end
    end

    context 'Missing Work Report' do 
      let(:days_missed) { 5 }

      before(:example) do
        Employee.all.each {|employee| 
          missed = days_missed
          date = start_date
          while date <= end_date
            Timelog.create(
              employee: employee,
              log_date: date,
              arrive_sec: (missed > 0 ? nil : date + 9.hours),
              leave_sec: (missed > 0 ? nil : date + 18.hours)
            )
            missed -= 1
            date += 1.day
          end
        }
      end

      it "assigns the requested timelogs as @timelogs" do
        employee = controller.current_employee        
        test_params = report_params
        test_params[:type] = 'missed_work'
        get :assistance, report_params
        expect(assigns(:timelogs).count).to eq(days_missed * Employee.count)
      end
    end
  end

  describe '.print_timesheet_period' do
    it "returns a string displaying the period range" do
      ts = timesheets(:john)
      res = Timesheet.print_timesheet_period(ts)
      expect(res).to have_text ts.period_start_date.strftime('%d/%b/%Y')
      expect(res).to have_text ts.period_end_date.strftime('%d/%b/%Y')
    end
  end

end
