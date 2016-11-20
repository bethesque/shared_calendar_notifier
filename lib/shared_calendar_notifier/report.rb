module SharedCalendarNotifier
  class ReportBuilder
    def self.build_report for_user_email_address, events, created_after_date
      Report.new(
        :for_user_email_address => for_user_email_address,
        :events => events.find_all{ | event| event.status != 'cancelled' && event.updated >= created_after_date && event.creator.email != for_user_email_address },
        :created_after_date => created_after_date)
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
