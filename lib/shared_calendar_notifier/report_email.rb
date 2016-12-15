require 'active_support/time'
require 'tzinfo'
require 'mail'
require 'shared_calendar_notifier/logging'
require 'shared_calendar_notifier/date_helper'

module SharedCalendarNotifier
  class ReportEmail

    include Logging
    include DateHelper

    EVENT_COUNT_IN_SUBJECT = 2

    def initialize report, bcc
      @report = report
      @bcc = bcc
    end

    def recipient
      report.for_user_email_address
    end

    def subject
      "#{event_summaries_for_subject}#{more_events}"
    end

    def body
      event_body_descriptions_for(events).join("\n")
    end

    def to_s
      "Email to: #{recipient}, from: #{from}, subject: '#{subject}', body:\n#{body}"
    end

    def from
      "\"New shared events with Beth maybe\" <#{ENV['MAIL_SENDER']}>"
    end

    def send
      mail = Mail.new
      mail.from = self.from
      mail.to = self.recipient
      mail.bcc = bcc if
      mail.subject = self.subject
      mail.body = self.body
      logger.info("Sending email (with bcc: #{mail.bcc}):\n#{mail.to_s}")
      mail.deliver
      self
    end

    private

    def more_events
      events.size > EVENT_COUNT_IN_SUBJECT ? ", plus #{events.size - EVENT_COUNT_IN_SUBJECT} more..." : ''
    end

    def event_summaries_for_subject
      events.collect{|event| event.summary}.join(", ")
    end

    def subject_events
      events.take(EVENT_COUNT_IN_SUBJECT)
    end

    def event_descriptions_for events
      events.collect{|event| event_description(event)}
    end

    def event_description event
      desc = event.summary.dup
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
        relative_date_in_words(event.start.date_time.to_date)
      elsif event.start.date
        relative_date_in_words(Date.parse(event.start.date))
      else
        nil
      end
    end

    def days_away date_time
      (date_time.to_date - DateTime.now.to_date).to_i
    end

    attr_reader :report, :bcc

    def events
      report.events
    end
  end
end