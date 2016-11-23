module SharedCalendarNotifier
  module DateHelper

    def days_away_in_words number_of_days, from_date = Date.today
      weekday_name = (from_date + number_of_days).strftime('%A')
      if number_of_days < 0
        "In the past"
      elsif number_of_days == 0
        "Today"
      elsif number_of_days <= 6
        "This #{weekday_name}"
      elsif number_of_days <= 13
        "#{weekday_name} week"
      else
        "#{weekday_name} in #{(number_of_days/7).to_i} weeks"
      end
    end

    def relative_date_in_words date, from_date = Date.today
      days_away_in_words((date - from_date).to_i, from_date)
    end

  end
end
