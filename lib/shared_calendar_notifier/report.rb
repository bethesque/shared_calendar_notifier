module SharedCalendarNotifier
  class ReportBuilder
    def self.build_report for_user, events, created_after_date
      Report.new(
        :user => for_user,
        :events => events.find_all{ | event| event.updated >= created_after_date && event.creator.email != for_user.email },
        :created_after_date => created_after_date)
    end
  end

  class Report
    attr_reader :user
    attr_reader :events
    attr_reader :created_after_date

    def initialize params
      @user = params[:user]
      @events = params[:events]
      @created_after_date = params[:created_after_date]
    end

    def any_events?
      events.any?
    end

    def to_s
      "Report for #{user.display_name} with events: #{events.collect(&:summary).join(', ')}"
    end
  end
end
