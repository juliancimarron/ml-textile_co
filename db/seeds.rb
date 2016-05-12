# Configuration
departments = [
  'Sales',
  'Marketing',
  'Development',
  'Management'
]
number_of_employees = 5 # will create 1 admin and rest regular


# Utilities
dotted = '------------'

dist_rand = lambda {|values, distr, has_sign|
  return unless values.size == distr.size
  r = rand(0..99)
  value_index = distr.index {|x| x > r}
  value = values[value_index]
  return has_sign ? [1,-1].sample * value : value
}


# Departments
ActiveRecord::Base.transaction do
  departments.each do |dept|
    Department.create({name: dept})
  end
end
puts "Finished seeding Department data."
puts dotted

# Employees
puts "Now seeding Employee data."
puts "#{number_of_employees} records will be created."
departments = Department.all
ActiveRecord::Base.transaction do
  sum = 0
  while number_of_employees > 1 do
    puts "#{sum} records created" if sum % 100 == 0
    Employee.create(
      first_name: FFaker::Name.first_name,
      last_name: FFaker::Name.last_name,
      department: dist_rand[departments, [40, 50, 90, 100], false],
      password: '123456'
    )
    sum += 1
    number_of_employees -= 1
  end
  if number_of_employees == 1
    Employee.create(
      first_name: 'Julian',
      last_name: 'Hernandez',
      department: departments.last,
      admin: true,
      password: '123456'
    )
  end
end
puts "Finished seeding Employee data."
puts dotted


# Timelogs
puts "Now seeding Timelog data."
date = Date.new(2016, 4, 1) - 1.day
puts "These records will run to #{Date.new 2016,6,30}"
ActiveRecord::Base.transaction do
  while date.month < 7
    puts date += 1.day
    next if [0,6].include? date.wday
    Employee.all.each do |emp|
      arrive = date.to_datetime + 9.hours + dist_rand[
        [0, rand(1..30).minutes], [90, 100], true
      ].seconds
      leave = date.to_datetime + 18.hours + dist_rand[
        [0, rand(1..30).minutes], [90, 100], true
      ].seconds
      claim_arrive = rand(0..99) > 95 ? arrive + dist_rand[[rand(30..60).minutes], [100], true].seconds : nil
      claim_leave = rand(0..99) > 95 ? arrive + dist_rand[[rand(30..60).minutes], [100], true].seconds : nil
      Timelog.create(
        employee_id: emp.employee_id,
        log_date: date,
        arrive_datetime: arrive,
        leave_datetime: leave,
        claim_arrive_datetime: claim_arrive,
        claim_leave_datetime: claim_leave,
        claim_status: (claim_arrive.nil? and claim_leave.nil?) ? nil : Timelog::CLAIM_STATUS_OPT.sample
      )
    end
  end
end
puts "Finished seeding Timelog data."
puts dotted


# Timesheet
puts "Now seeding Timesheet data."
date_ini = Date.new(2016,4,1)
date_end = Date.new(date_ini.year, date_ini.month, -1)
ActiveRecord::Base.transaction do
  while date_ini.month < 7
    puts date_ini
    Employee.all.each do |emp|
      seconds = Timelog.where(
        'employee_id = ? AND log_date >= ? AND log_date <= ?',
        emp.id, date_ini, date_end
      ).map{|x| 
        arrive = x.arrive_datetime
        leave = x.leave_datetime
        if ['pending','approved'].include? x.claim_status
          arrive = x.claim_arrive_datetime unless x.claim_arrive_datetime.nil?
          leave = x.claim_leave_datetime unless x.claim_leave_datetime.nil?
        end
        leave - arrive
      }.inject(:+).to_i
      Timesheet.create(
        employee: emp,
        period_start_date: date_ini,
        period_end_date: date_end,
        logged_hrs: Util.seconds_to_hrs_min(seconds)[:hours],
        logged_min: Util.seconds_to_hrs_min(seconds)[:minutes],
        pay_date: date_end + 7.days
      )
    end
    date_ini = Date.new(date_ini.year, date_ini.month + 1, 1)
    date_end = Date.new(date_ini.year, date_ini.month, -1)
  end
end
puts "Finished seeding Timesheet data"
puts dotted
puts "All seed data how now been added successfully."
