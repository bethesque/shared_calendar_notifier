require 'active_support/time'
require 'tzinfo'
require 'mail'
require 'shared_calendar_notifier/logging'

module SharedCalendarNotifier
  class ReportEmail

    include Logging

    EVENT_COUNT_IN_SUBJECT = 2

    def initialize report
      @report = report
    end

    def recipient
      report.user.email
    end

    def subject
      "#{event_summaries_for_subject}#{more_events}"
    end

    def body
      (["New shared events:"] + event_body_descriptions_for(events)).join("\n")
    end

    def to_s
      "Email to: #{recipient}, from: #{from}, subject: '#{subject}', body:\n#{body}"
    end

    def from
      "\"New shared events\" <#{ENV['MAIL_SENDER']}>"
    end

    def send
      logger.debug("Sending #{to_s}")
      mail = Mail.new
      mail.from = from
      mail.to = recipient
      mail.subject = subject
      mail.body = body
      mail.deliver
    end

    private

    def more_events
      events.size > EVENT_COUNT_IN_SUBJECT ? ", plus #{events.size - EVENT_COUNT_IN_SUBJECT} more..." : ''
    end

    def event_summaries_for_subject
      event_descriptions_for(subject_events).join(", ")
    end

    def subject_events
      events.take(EVENT_COUNT_IN_SUBJECT)
    end

    def event_descriptions_for events
      events.collect{|event| event_description(event)}
    end

    def event_description event
      desc = event.summary
      if start = formatted_event_start_time(event)
        desc << " - #{start}"
      end
      desc
    end

    def event_body_descriptions_for events
      events.collect{|event| event_body_description_for(event)}
    end

    def event_body_description_for event
      event_description(event) + (event.location ? " at #{event.location}" : '')
    end

    def formatted_event_start_time event
      if event.start.date_time
        event.start.date_time.in_time_zone.strftime('%a %d %b %Y %l:%M %P').gsub("  ", " ")
      else
        nil
      end
    end

    def report
      @report
    end

    def events
      report.events
    end
  end
end