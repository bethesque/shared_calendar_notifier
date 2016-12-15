module SharedCalendarNotifier
  class ReportBuilder
    def self.build_report for_user_email_address, events, created_after_date
      Report.new(
        :for_user_email_address => for_user_email_address,
        :events => filter_and_sort_events(for_user_email_address, events, created_after_date),
        :created_after_date => created_after_date)
    end

    def self.filter_and_sort_events for_user_email_address, events, created_after_date
      events.find_all do | event|
        event.status != 'cancelled' &&
        event.updated >= created_after_date &&
        event.creator.email != for_user_email_address
      end.sort do | event_1, event_2 |
        date_1 = event_1.start.date_time || event_1.start.date.to_date
        date_2 = event_2.start.date_time || event_2.start.date.to_date
        date_1 <=> date_2
      end
    end
  end

  class Report
    attr_reader :for_user_email_address
    attr_reader :events
    attr_reader :created_after_date

    def initialize params
      @for_user_email_address = params[:for_user_email_address]
      @events = params[:events]
      @created_after_date = params[:created_after_date]
    end

    def any_events?
      events.any?
    end

    def to_s
      "Report for #{for_user_email_address} with events: #{events.collect(&:summary).join(', ')}"
    end
  end
end
