json.array!(@timelogs) do |timelog|
  json.extract! timelog, :id, :employee_id, :log_date, :arrive_datetime, :leave_datetime, :claim_arrive_datetime, :claim_leave_datetime, :claim_status
  json.url timelog_url(timelog, format: :json)
end
