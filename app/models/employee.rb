class Employee < ActiveRecord::Base
  belongs_to :department
  has_many :timelogs
  has_many :timesheets
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :omniauthable, :validatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  validates :first_name,
    presence: true

  validates :last_name,
    presence: true

  validates :department_id,
    presence: true,
    numericality: {
      only_integer: true,
    },
    inclusion: {      
      in: :department_ids
    }

  def department_ids
    Department.all.pluck(:id)
  end

  def full_name 
    "#{first_name} #{last_name}"
  end

end
