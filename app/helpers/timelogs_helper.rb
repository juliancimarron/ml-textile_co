module TimelogsHelper

  def timelog_moment_in_time(moment, timelog) 
    moment_i = Timelog.get_correct_moment(moment, timelog)
    res = moment_i ? (DateTime.new(2016) + moment_i.seconds).strftime('%l:%M %p') : 'Missing'
    return res
  end

  def moment_as_time_for_edit(moment, if_nil) 
    res = moment ? (DateTime.new(2016) + moment.seconds).strftime('%l:%M %p') : if_nil
    return res
  end

  def print_late_by(arrive_time, timelog) 
    correct_arrive_sec = (timelog.log_date.to_datetime + arrive_time).to_i - timelog.log_date.to_datetime.to_i
    res = 'N/A'

    if arrive_sec = Timelog.get_correct_moment(:arrive, timelog)
      sec_diff = arrive_sec ? (arrive_sec - correct_arrive_sec) : 0
      res = sec_diff > 0 ? "#{sec_diff / 60} minutes" : nil
    end

    return res
  end

  def reported_error_action(timelog) 
    case timelog.claim_status
    when 'pending'
      approve = link_to 'Approve', 
        admin_timelogs_reported_error_path(timelog.id, claim_status: 'approved'),
        method: :put
      decline = link_to 'Decline', 
        admin_timelogs_reported_error_path(timelog.id, claim_status: 'declined'),
        method: :put
      return "#{approve} / #{decline}".html_safe
    when 'approved'
      link_to 'Change to Decline', 
        admin_timelogs_reported_error_path(timelog.id, claim_status: 'declined'),
        method: :put
    when 'declined'
      link_to 'Change to Approve', 
        admin_timelogs_reported_error_path(timelog.id, claim_status: 'approved'),
        method: :put
    end
  end

end
