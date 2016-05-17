require 'rails_helper'
require 'support/model_attributes'
require 'support/shared_context'

RSpec.describe TimelogsController, type: :controller do
  include_context 'model_attributes'
  include_context 'create_timelogs'

  fixtures :timelogs
  fixtures :employees

  let(:valid_timelog) { timelogs(:julian) }
  let(:reg_employee) { employees(:john) }
  let(:admin_employee) { employees(:julian) }

  before(:example) { sign_in admin_employee } 

  context 'authorization' do 
    it "redirects to sign in if user not logged in" do
      sign_out employees(:julian)
      get :index
      expect(response).to redirect_to new_employee_session_path
    end
  end

  describe "GET #index" do
    def get_timelogs(start_date, end_date, employee) 
      Timelog.where(
        'employee_id = ? AND log_date >= ? AND log_date <= ?',
        employee, start_date, end_date)
    end

    before(:example) do
      sign_in reg_employee
      today = Time.now.to_date
      Timelog.delete_all
      create_timelogs (today - 9.months), (today - 8.months), reg_employee, true
      create_timelogs (today - 3.months), (today - 2.month), reg_employee, true
      create_timelogs (today + 3.months), (today + 5.months), reg_employee, true
    end

    it "assigns last 5 months of employee's timelogs to @timelogs" do
      period_start = Time.now.to_date - 4.months
      period_start = Date.new period_start.year, period_start.month
      period_end = Date.new Time.now.year, Time.now.month, -1
      timelogs = get_timelogs(period_start, period_end, controller.current_employee)

      get :index
      expect( assigns(:timelogs).count ).to eq timelogs.count
      expect( assigns(:timelogs).first ).to be_a(Timelog)
    end

    describe "assigns last 5 months of period titles to @periods and selects an active one" do
      let(:periods) { 5 }

      before(:example) { get :index }

      specify{ expect( assigns(:periods)[:collection].first ).to be_an(Array) }
      specify{ expect( assigns(:periods)[:collection].first.first ).to be_an(String) }
      specify{ valid_date = Date.parse assigns(:periods)[:collection].first[1].to_s
        expect( valid_date ).to be_a(Date) }
      specify{ expect( assigns(:periods)[:collection].count ).to eq periods }
      specify{ expect( assigns(:periods)[:active] ).to be_a(String) }
    end

    it "assigns processed timelogs as @proc_timelogs" do
      period_start = Time.now.to_date - 4.months
      period_start = Date.new period_start.year, period_start.month
      period_end = Date.new Time.now.year, Time.now.month, -1
      timelogs = get_timelogs(period_start, period_end, controller.current_employee)
      period_business_days = 0

      date = period_start
      while date <= period_end
        period_business_days += 1 unless [6,7].include? date.cwday
        date += 1.day
      end

      get :index, {timelogs: {period: period_start.to_s}}
      expect( assigns(:proc_timelogs) ).to be_an(Array)
      expect( assigns(:proc_timelogs).count ).to be < period_business_days # employee skipped some work days
    end

    it "assigns accumulated time for period as @timelogs_time" do
      get :index
      expect( assigns(:timelogs_time)[:hours] ).to be_a(Fixnum)
      expect( assigns(:timelogs_time)[:minutes] ).to be_a(Fixnum)
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

    it "redirects to show view if claim_status = approved" do
      valid_timelog.update claim_status: 'approved'
      valid_timelog.reload
      get :edit, {:id => valid_timelog.id}
      expect(response).to redirect_to timelogs_url
    end

    it "assigns the string for the corresponding pay period as @period" do
      get :edit, {id: valid_timelog.id}
      expect( assigns(:period) ).to be_a(String)
      expect( assigns(:period).index /\w\w\/\w\w\w\/\w\w\w\w/ ).to be >= 0
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
      Timelog.delete_all
    end

    context 'Tardies Report' do 
      let(:days_late) { 7 }
      before(:example) do
        Employee.all.each {|employee| 
          late = days_late
          date = start_date
          while date <= end_date
            date += 1 and next if [6,7].include? date.cwday
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
            date += 1 and next if [6,7].include? date.cwday
            missed -= 1 and date += 1.day and next if missed > 0
            Timelog.create(
              employee: employee,
              log_date: date,
              arrive_sec: arrival,
              leave_sec: departure
            )
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

  describe "GET #reported_errors" do
    let(:start_date) { Time.now.to_date - 3.months }
    let(:end_date) { Time.now.to_date }

    before(:example) do
      sign_out employees(:john)
      sign_in admin_employee

      Timelog.delete_all

      Employee.all.each do |employee|
        create_timelogs(start_date - 2.months, end_date, employee, true)
      end

      Timelog.all.each do |timelog|
        next if dist_rand([false, true], [50,100], false)
        timelog.update(
          claim_arrive_sec: (8.hours + 30.minutes),
          claim_leave_sec: (18.hours + 30.minutes),
          claim_status: dist_rand(%w(pending approved declined), [33,66,100], false)
        )
      end
    end

    it "assigns timelogs with reported errors as @timelogs" do
      timelog_errors = Timelog.where(
        '(claim_status = ?) OR (log_date >= ? AND log_date <= ? AND claim_status IN (?))',
        'pending', start_date, end_date, ['approved', 'declined'])
      get :reported_errors
      expect(assigns(:timelogs).count).to eq timelog_errors.count
    end

    it "assigns timelogs with claim_status = 'pending' to @timelogs" do
      ids = Timelog.where(
        'claim_status == ? AND log_date >= ? AND log_date <= ?',
        'pending', start_date, end_date).pluck(:id)
      get :reported_errors
      expect(assigns(:timelogs).where(id: ids).count).to eq ids.count
    end

    it "assigns timelogs with claim_status = 'appoved' from the last 3 months" do
      ids = Timelog.where(
        'claim_status == ? AND log_date >= ? AND log_date <= ?',
        'approved', start_date, end_date).pluck(:id)
      get :reported_errors
      expect(assigns(:timelogs).where(id: ids).count).to eq ids.count
    end

    it "assigns timelogs with claim_status = 'declined' from the last 3 months" do
      ids = Timelog.where(
        'claim_status == ? AND log_date >= ? AND log_date <= ?',
        'declined', start_date, end_date).pluck(:id)
      get :reported_errors
      expect(assigns(:timelogs).where(id: ids).count).to eq ids.count
    end
  end

end
