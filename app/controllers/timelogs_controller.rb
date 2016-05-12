class TimelogsController < ApplicationController
  before_action :set_timelog, only: [:show, :edit, :update, :destroy]
  before_action :set_current_timesheet, only: [:index, :update]

  # GET /timelogs
  # GET /timelogs.json
  def index
    @timesheets = Timesheet.where(employee: current_employee)
      .order(period_start_date: :asc)
    @timesheet_ids = @timesheets.map{|x|
      [Timesheet.print_timesheet_period(x), x.id]}
    @proc_timelogs = process_timelogs(@current_timesheet)
  end

  # GET /timelogs/1
  # GET /timelogs/1.json
  def show
  end

  # GET /timelogs/new
  def new
    @timelog = Timelog.new
  end

  # GET /timelogs/1/edit
  def edit
  end

  # POST /timelogs
  # POST /timelogs.json
  def create
    @timelog = Timelog.new(timelog_params)

    respond_to do |format|
      if @timelog.save
        format.html { redirect_to @timelog, notice: 'Timelog was successfully created.' }
        format.json { render :show, status: :created, location: @timelog }
      else
        format.html { render :new }
        format.json { render json: @timelog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /timelogs/1
  # PATCH/PUT /timelogs/1.json
  def update
    respond_to do |format|
      if @timelog.update(timelog_params)
        format.html { redirect_to @timelog, notice: 'Timelog was successfully updated.' }
        format.json { render :show, status: :ok, location: @timelog }
      else
        format.html { render :edit }
        format.json { render json: @timelog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /timelogs/1
  # DELETE /timelogs/1.json
  def destroy
    @timelog.destroy
    respond_to do |format|
      format.html { redirect_to timelogs_url, notice: 'Timelog was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def timelog_params
      params.require(:timelog).permit(:employee_id, :log_date, :arrive_datetime, :leave_datetime, :claim_arrive_datetime, :claim_leave_datetime, :claim_status)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_timelog
      @timelog = Timelog.where(id: params[:id]).first

      if @timelog.nil?
        notice = 'The Timelog searched could not be found.'
        redirect_to(timelogs_path, notice: notice) and return
      end

      if @timelog.employee_id != current_employee.id
        notice = 'You attempted an unauthorized action.'
        redirect_to timelogs_path, notice: notice
      end
    end

    def set_current_timesheet 
      timesheets = Timesheet.where(employee: current_employee)
        .order(period_start_date: :asc)
      params_ts_id = params.fetch(:timelogs, {}).fetch(:timesheet_id, timesheets.last.id)
      unless timesheet = timesheets.where(id: params_ts_id).first
        notice = 'You attempted an unauthorized action.'
        redirect_to(root_url, notice: notice) and return
      end
      @current_timesheet = timesheet
    end

    def process_timelogs(timesheet) 
      period_minutes = 0
      processed_timelogs = []

      Timelog.where(
        'employee_id = ? AND log_date >= ? AND log_date <= ?',
        current_employee.id,
        timesheet.period_start_date,
        timesheet.period_end_date
      ).order(log_date: :asc).each do |timelog|
        hash = {}
        hash[:log_date] = timelog.log_date.strftime '%a, %d-%b-%Y'
        hash[:action] = {}

        arrive = timelog.arrive_datetime
        leave = timelog.leave_datetime
        if ['pending','approved'].include? timelog.claim_status
          arrive = timelog.claim_arrive_datetime unless timelog.claim_arrive_datetime.nil?
          leave = timelog.claim_leave_datetime unless timelog.claim_leave_datetime.nil?
        end
        hash[:arrive_time] = arrive.strftime '%l:%M %p'
        hash[:leave_time] = leave.strftime '%l:%M %p'

        seconds = (leave - arrive).to_i
        hash[:hours] = Util.seconds_to_hrs_min(seconds)[:hours]
        hash[:minutes] = Util.seconds_to_hrs_min(seconds)[:minutes]
        period_minutes += hash[:minutes] + hash[:hours] * 60

        # if timesheet.pay_date - 3.days == Time.now.to_date
        if true
          link = edit_timelog_path(timelog.id)
          case timelog.claim_status
          when ''
            hash[:action][:text] = 'Report Error'
            hash[:action][:path] = link
          when 'pending'
            hash[:action][:text] = 'Edit Report' 
            hash[:action][:path] = link
          end
        end
        
        case timelog.claim_status
        when 'pending'
          hash[:status] = 'Pending Review'
        when 'approved'
          hash[:status] = 'Claim Approved'
        when 'declined'
          hash[:status] = 'Claim Declined'
        end

        processed_timelogs << hash
      end

      timesheet.logged_hrs = period_minutes / 60
      timesheet.logged_min = period_minutes - timesheet.logged_hrs * 60
      timesheet.save

      return processed_timelogs
    end
end
