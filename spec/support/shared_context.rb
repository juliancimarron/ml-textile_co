RSpec.shared_context 'create_timelogs' do

  def dist_rand(values, distr, has_sign)
    return unless values.size == distr.size
    r = rand(0..99)
    value_index = distr.index {|x| x > r}
    value = values[value_index]
    return has_sign ? [1,-1].sample * value : value
  end

  def create_timelogs(start_date, end_date, employee, has_days_skipped) 
    d_values = [0, rand(1..30).minutes]
    d_weights = [90, 100]
    timelogs = []

    current_date = start_date
    while current_date <= end_date
      current_date += 1.day and next if [6,7].include? current_date.cwday  # skip Weekends
      if has_days_skipped
        current_date += 1.day and next if dist_rand([false,true], [95,100], false)
      end
      
      timelog_attributes = {
        employee_id: employee.id,
        log_date: current_date,
        arrive_sec: (9.hours + dist_rand(d_values, d_weights, true).seconds),
        leave_sec: (18.hours + dist_rand(d_values, d_weights, true).seconds)
      }
      timelogs << timelog_attributes
      current_date += 1.day
    end
    Timelog.create timelogs
  end

  def month_workdays(year, month) 
    date = Date.new(year, month) - 1.day
    workdays = 0
    while date.month <= month
      date += 1.day
      next if [6,0].include? date.wday
      workdays += 1
    end
    return workdays
  end


end
