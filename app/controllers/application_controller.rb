class ApplicationController < ActionController::API
  def check_user_plan_expiry
    if current_user.active_plan
      time = generate_time(DateTime.now)
      if time.to_i >= current_user.plan_duration
        active_plan = ActivePlan.find_by(user_id: current_user.id)
        if active_plan.destroy
          user = User.find(current_user.id)
          UserMailer.plan_expires(user).deliver_later
          user.active_plan = false
          user.plan_duration = 0
          user.expiry_date = nil
          user.save
        end
      end
    end
  end

  def generate_time(time)
    date = ''
    date += time.year.to_s
    date += '0' if time.month.to_i < 10
    date += time.month.to_s
    date += '0' if time.day.to_i < 10
    date += time.day.to_s
    return date
  end

  class Exception < StandardError
    class UserNotLoggedIn < Exception
      def message
        "User is not logged in"
      end
    end
    def self.handle(current_user)
      raise UserNotLoggedIn if !current_user
    end
  end
end