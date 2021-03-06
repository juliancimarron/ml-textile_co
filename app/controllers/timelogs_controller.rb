class TimelogsController < ApplicationController
  before_action :set_timelog, only: [:edit, :show, :update]
  before_action :authorize_employee, only: [:assistance, :reported_errors, :reported_error_update]

  # GET /timelogs
  # GET /timelogs.json
  def index
    today = Time.now.to_date
    timeframe_start = today - 4.months
    timeframe_start = Date.new timeframe_start.year, timeframe_start.month
    timeframe_end = Date.new today.year, today.month, -1
    
    @timelogs = Timelog.where(
      'employee_id = ? AND log_date >= ? AND log_date <= ?',
      current_employee.id, timeframe_start, timeframe_end
    ).order(log_date: :desc)
    
    @periods = {collection: [], active: nil}
    period_start = timeframe_start
    period_end = Date.new period_start.year, period_start.month, -1
    while period_start <= timeframe_end
      period = period_start.strftime('%d/%b/%Y') + ' –– ' +  period_end.strftime('%d/%b/%Y')
      @periods[:collection] << [period, period_start]
      period_start = period_end + 1.day
      period_end = Date.new period_start.year, period_start.month, -1
    end
    @periods[:active] = params.fetch(:timelogs, {}).fetch(:period, @periods[:collection].last[1].to_s)

    view_start_date = Date.parse @periods[:active]
    view_end_date = Date.new view_start_date.year, view_start_date.month, -1
    timelogs_data = Timelog.timelogs_for_index_view(@timelogs, view_start_date, view_end_date)
    @timelogs_time = timelogs_data[:time]
    @proc_timelogs = timelogs_data[:timelogs]
  end

  # GET /timelogs/1
  # GET /timelogs/1.json
  def show
    @period = print_pay_timeframe(@timelog.log_date, @timelog.log_date).first
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
    @period = print_pay_timeframe(@timelog.log_date, @timelog.log_date).first
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
      tardies: 'timelogs_tardies(@report_q[:start_date], @report_q[:end_date])', 
      missed_work: 'timelogs_missed_work(@report_q[:start_date], @report_q[:end_date])'
    }

    @timelogs = eval(run_report[@report_q[:type].to_sym])

    @report_q[:chart_all] = Timelog
      .where('log_date >= ? AND log_date <= ?', @report_q[:start_date], @report_q[:end_date])
      .count
    @report_q[:chart_part] = @timelogs.count
    @report_q[:chart_label_all] = @report_q[:type] == 'tardies' ? 'On Time' : 'Worked'
    @report_q[:chart_label_part] = @report_q[:type] == 'tardies' ? 'Late' : 'Missed Work'
  rescue Exception => e
    notice = 'There was an error processing the report.'
    redirect_to assistance_url, notice: notice
  end

  # GET /reported_errors
  def reported_errors 
    start_date = Time.now.to_date - 3.months
    end_date = Time.now.to_date

    @timelogs = Timelog
      .where('(claim_status = ?) OR (log_date >= ? AND log_date <= ? AND claim_status IN (?))',
        'pending', start_date, end_date, ['approved', 'declined'])
      .order(log_date: :asc)
  end

  # PUT /reported_errors/:id/udpate
  def reported_error_update 
    possible_statuses = %w(pending approved declined)
    timelog = Timelog.where(id: params[:id]).first
    new_status = params[:claim_status]

    timelog = timelog.claim_status.nil? ? nil : timelog
    new_status = possible_statuses.include?(new_status) ? new_status : nil
    redirect_to(admin_timelogs_reported_errors_path) and return if timelog.nil? or new_status.nil?

    timelog.update claim_status: new_status
    redirect_to admin_timelogs_reported_errors_path, notice: "Timelog successfully updated."
  rescue Exception => e
    redirect_to admin_timelogs_reported_errors_path, alert: "There was an error processig your request."
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
      missed_work = []
      timelogs = Timelog.where('log_date >= ? AND log_date <= ?', start_date, end_date)

      Employee.all.each do |employee|
        date = start_date
        while date <= end_date
          date += 1 and next if [6,7].include? date.cwday # skip weekends        
          unless timelogs.where(employee: employee, log_date: date).any?
            fake_timelog = Struct.new(:log_date, :employee, :arrive_sec, :leave_sec, :claim_arrive_sec, :claim_leave_sec, :claim_status).new
            fake_timelog.log_date = date
            fake_timelog.employee = employee
            missed_work << fake_timelog
          end
          date += 1.day
        end
      end

      return missed_work
    end

    def print_pay_timeframe(start_date, end_date) 
      period_start = start_date
      period_end = Date.new period_start.year, period_start.month, -1
      periods = []
      while period_start <= end_date
        periods << period_start.strftime('%d/%b/%Y') + ' –– ' +  period_end.strftime('%d/%b/%Y')
        period_start = period_end + 1.day
        period_end = Date.new period_start.year, period_start.month, -1
      end

      return periods
    end

end
