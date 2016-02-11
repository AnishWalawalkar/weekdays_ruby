module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module Date #:nodoc:
      # Enables the use of time calculations within Date itself
      module Calculations
        # Tells whether the Date object is a weekday
        def weekday?
          return (1..5).include?(wday)
        end

        def businessday?
          return true if (1..5).include?(wday)
          return self.business_weekends.include?(self) ? true : false
        end

        # Returns the number of weekdays until a future Date
        def weekdays_until(until_date)
          return 0 if until_date <= self
          #(self...date).select{|day| day.weekday?}.size + (self.weekday? ? 0 : 1) + (date.weekday? ? 0 : -1)

          # Convert from/to dates to weekdays to reduce calculation to simple math
          from_date = self
          from_date = from_date-2.days if from_date.wday == 0 # change from date from Sunday to Friday
          from_date = from_date-1.day if from_date.wday == 6  # change from date from Saturday to Friday
          until_date = until_date-2.days if until_date.wday == 0 # change until_date from Sunday to Friday
          until_date = until_date-1.day if until_date.wday == 6  # change until_date from Saturday to Friday
          total_days = (until_date-from_date).to_i
          num_weekdays = total_days/7*5 + (until_date.wday-from_date.wday + (until_date.wday-from_date.wday < 0 ? 5 : 0))
        end

        def businessdays_until(until_date)
          weekend_numbers = [0, 6]
          until_date -= 1
          weekend_count = self.business_weekends ? (self..until_date).select{|dt| self.business_weekends.include?(dt)}.to_a.size : 0
          count = (self..until_date).reject{|dt| weekend_numbers.include?(dt.wday)}.to_a.size
          return (weekend_count + count)
        end

        def next_weekday
          return self if self.weekday?
          next_weekday = self.wday == 0 ? 1 : 2
          self + next_weekday.days
        end

        def next_businessday
          return self.next_weekday unless self.business_weekends
          return self if self.business_weekends.include?(self)
          day_count = 0
          if self.wday == 6
            if self.business_weekends.include?(self+1)
              day_count = 1
            else
              day_count = 2
            end
          elsif self.wday == 0
            day_count = 1
          end
          return self + day_count
        end

        def prev_weekday
          return self if self.weekday?
          prev_weekday = self.wday == 0 ? 2 : 1
          self - prev_weekday.days
        end

        def prev_businessday
          return self.prev_weekday unless self.business_weekends
          return self if self.business_weekends.include?(self)
          day_count = 0
          if self.wday == 6
            day_count = 1
          elsif self.wday == 0
            if self.business_weekends.include?(self -1)
              day_count = 1
            else
              day_count = 2
            end
          end
          return self - day_count
        end
      end
    end
  end
end

class Date
  include ActiveSupport::CoreExtensions::Date::Calculations
end

module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module Time #:nodoc:
      # Enables the use of time calculations within Time itself
      module Calculations
        def weekday?
          (1..5).include?(wday)
        end

        def businessday?
          return true if (1..5).include?(wday)
          return self.business_weekends.include?(self) ? true : false
        end

        def weekdays_until(until_date)
          return 0 if until_date <= self.to_date
          #(self.to_date...date).select{|day| day.weekday?}.size + (self.to_date.weekday? ? 0 : 1) + (date.to_date.weekday? ? 0 : -1)

          # Convert from/to dates to weekdays to reduce calculation to simple math
          from_date = self.to_date
          from_date = from_date-2.days if from_date.wday == 0 # change from date from Sunday to Friday
          from_date = from_date-1.day if from_date.wday == 6  # change from date from Saturday to Friday
          until_date = until_date-2.days if until_date.wday == 0 # change until_date from Sunday to Friday
          until_date = until_date-1.day if until_date.wday == 6  # change until_date from Saturday to Friday
          total_days = (until_date-from_date).to_i
          num_weekdays = total_days/7*5 + (until_date.wday-from_date.wday + (until_date.wday-from_date.wday < 0 ? 5 : 0))
        end

        def weekdays_until_with_weekends(until_date)
          weekend_numbers = [0, 6]
          until_date -= 1
          weekend_count = self.business_weekends ? (self..until_date).select{|dt| self.business_weekends.include?(dt)}.to_a.size : 0
          count = (self..until_date).reject{|dt| weekend_numbers.include?(dt.wday)}.to_a.size
          return (weekend_count + count)
        end

      end
    end
  end
end

class Time
  include ActiveSupport::CoreExtensions::Time::Calculations
end

module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module DateTime #:nodoc:
      # Enables the use of time calculations within DateTime itself
      module Calculations
        # Tells whether the Date object is a weekday
        def weekday?
          (1..5).include?(wday)
        end

        def businessday?
          return true if (1..5).include?(wday)
          return self.business_weekends.include?(self) ? true : false
        end
      end
    end
  end
end

class Time
  include ActiveSupport::CoreExtensions::DateTime::Calculations
end

module ActiveSupport #:nodoc:
  module CoreExtensions
    module Numeric
      module Time
        # Returns a Time object that is n number of weekdays in the future of a given Date
        def weekdays_from(time = ::Time.now)
          # -5.weekdays_from(time) == 5.weekdays_ago(time)
          return self.abs.weekdays_ago(time) if self < 0

          x = 0
          curr_date = time

          until x == self
            curr_date += 1.days
            x += 1 if curr_date.weekday?
          end

          curr_date
        end
        alias :weekdays_from_now :weekdays_from

        # Returns a Time object that is n number of weekdays in the past from a given Date
        def weekdays_ago(time = ::Time.now)
          # -5.weekdays_ago(time) == 5.weekdays_from(time)
          return self.abs.weekdays_from(time) if self < 0

          x = 0
          curr_date = time

          until x == self
            curr_date -= 1.days
            x += 1 if curr_date.weekday?
          end

          curr_date
        end
      end
    end
  end
end

class Numeric
  include ActiveSupport::CoreExtensions::Numeric::Time
end
