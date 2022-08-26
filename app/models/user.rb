class User < ApplicationRecord
  devise :database_authenticatable,
    :jwt_authenticatable,
    :registerable,
    jwt_revocation_strategy: JwtDenylist

  validates :name, presence: true, length: { minimum: 3 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 7 }, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, message: "email format is invalid" }
  validates :age, presence: true
  validates :weight, presence: true

  def self.generate_time(time)
    date = ''
    date += time.year.to_s
    date += '0' if time.month.to_i < 10
    date += time.month.to_s
    date += '0' if time.day.to_i < 10
    date += time.day.to_s
    return date
  end

  def self.user_expiries
    users = User.all
    users.each do |user|
      if user.active_plan
        time = User.generate_time(DateTime.now)
        if time.to_i >= user.plan_duration
          active_plan = ActivePlan.find_by(user_id: user.id)
          if active_plan.destroy
            UserMailer.plan_expires(user).deliver_later
            user.active_plan = false
            user.plan_duration = 0
            user.expiry_date = nil
            user.save
          end
        end
      end
    end
  end
end
