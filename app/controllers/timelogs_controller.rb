class TimelogsController < ApplicationController
  before_action :set_timelog, only: [:edit, :show, :update]
  before_action :set_timesheet, only: [:edit, :show, :update]

  # GET /timelogs
  # GET /timelogs.json
  def index
    @timesheets = Timesheet.where(employee: current_employee)
    timesheet_id = params.fetch(:timelogs, {}).fetch(:timesheet_id, @timesheets.last.id)
    unless @timesheet = @timesheets.where(id: timesheet_id).first
      notice = 'Action could not be completed.'
      redirect_to(root_url, notice: notice) and return
    end

    @timesheets = @timesheets.order(period_start_date: :desc).limit(5).reverse
    @timesheet_ids = @timesheets.map{|x| [Timesheet.print_timesheet_period(x), x.id]}
    @proc_timelogs = Timelog.process_timelogs(@timesheet, current_employee)
  end

  # GET /timelogs/1
  # GET /timelogs/1.json
  def show
  end

  # GET /timelogs/new
  def new
    # disabled in routes
  end

  # GET /timelogs/1/edit
  def edit
    if @timelog.claim_status == 'approved'
      alert = 'The action attempted cannot be completed.'
      redirect_to(timelogs_path, alert: alert) and return
    end
  end

  # POST /timelogs
  # POST /timelogs.json
  def create
    # disabled in routes
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
    tl_updates = {}
    timelog_params.each do |k, v|
      v.strip!
      moment = %w(arrive leave).select{|x| k.include? x}[0]

      if v.empty?
        tl_updates["claim_#{moment}_sec"] = nil
      else
        dt = DateTime.parse "#{@timelog.log_date} #{v}"
        seconds_difference = dt.to_i - @timelog.log_date.to_datetime.to_i
        tl_updates["claim_#{moment}_sec"] = seconds_difference
        tl_updates[:claim_status] = 'pending'
      end
    end
    @timelog.update!(tl_updates)

    notice = 'Report successfully submitted.'
    redirect_to timelog_path(@timelog), notice: notice
  rescue Exception => e
    flash[:alert] = 'Invalid time format entered. Please follow the pattern "5:35 pm".'
    render :edit
  end

  # DELETE /timelogs/1
  # DELETE /timelogs/1.json
  def destroy
    # disabled in routes
    @timelog.destroy
    respond_to do |format|
      format.html { redirect_to timelogs_url, notice: 'Timelog was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /timelogs/assistance
  def assistance 
    today = Time.now.to_date
    @report_q = {}
    @report_q[:start_date] = Date.parse params[:start_date] ? params[:start_date] : (today - 60.days).to_s
    @report_q[:end_date] = Date.parse params[:end_date] ? params[:end_date] : today.to_s
    report_type_opt = Timelog::REPORT_TYPE_OPT.keys.map{|x| x.to_s}
    @report_q[:type] = report_type_opt.include?(params[:type]) ? params[:type] : report_type_opt.first
    run_report = {
      tardies: 'timelogs_tardies("#{@report_q[:start_date]}", "#{@report_q[:end_date]}")', 
      missed_work: 'timelogs_missed_work("#{@report_q[:start_date]}", "#{@report_q[:end_date]}")'
    }

    @timelogs = eval run_report[@report_q[:type].to_sym]
  rescue Exception => e
    notice = 'There was an error processing the report.'
    redirect_to assistance_url, notice: notice
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def timelog_params
      params.require(:timelog).permit(:claim_arrive_sec, :claim_leave_sec)
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

    def timelogs_date_range(start_date, end_date) 
      Timelog.where('log_date >= ? AND log_date <= ?',start_date, end_date)
        .order(log_date: :asc)
    end

    def timelogs_tardies(start_date, end_date) 
      timelogs_date_range(start_date, end_date)
        .select do |t|
          if t.arrive_sec.nil? and t.claim_arrive_sec.nil?
            false
          else
            case t.claim_status
            when 'pending', 'approved'
              9.hours < (t.claim_arrive_sec ? t.claim_arrive_sec : t.arrive_sec)
            when 'declined', NilClass
              9.hours < t.arrive_sec
            end
          end
        end
    end

    def timelogs_missed_work(start_date, end_date) 
      timelogs_date_range(start_date, end_date).select do |t|
        t.arrive_sec.nil? and t.claim_arrive_sec.nil? and 
        t.leave_sec.nil? and t.claim_leave_sec.nil?
      end
    end

    def set_timesheet
      @timesheet = Timesheet.where(
        'employee_id = ? AND period_start_date <= ? AND period_end_date >= ?',
        current_employee.id, @timelog.log_date, @timelog.log_date
      ).first

      unless @timesheet 
        notice = 'Action could not be completed.'
        redirect_to(root_url, notice: notice) and return
      end
    end
end
