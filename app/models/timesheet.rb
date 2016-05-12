class Timesheet < ActiveRecord::Base
  belongs_to :employee

  validates :employee_id,
    presence: true,
    numericality: {
      only_integer: true,
    },
    inclusion: {      
      in: :employee_ids
    }

  validates :period_start_date,
    presence: true

  validates :period_end_date,
    presence: true

  validates :logged_hrs,
    presence: true,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0
    }

  validates :logged_min,
    presence: true,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0
    }

  validates :pay_date,
    presence: true

  validate(
    :validate_period_end_date,
    :validate_pay_date
  )

  def employee_ids
    Employee.all.pluck(:employee_id)
  end

  def validate_period_end_date 
    return if period_end_date.nil? or period_start_date.nil?

    if period_end_date < period_start_date
      errors.add(:period_end_date, "The Period End Date cannot happen before the Period Start Date.")
    end
  end

  def validate_pay_date
    return if pay_date.nil? or period_end_date.nil?

    if pay_date < period_end_date
      errors.add(:pay_date, "The Pay Date cannot happen before the Period End Date.")
    end
  end
end
