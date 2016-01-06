require 'shared_calendar_notifier/version'
require 'shared_calendar_notifier/logging'
require 'shared_calendar_notifier/configuration'
require 'shared_calendar_notifier/report'
require 'shared_calendar_notifier/report_email'
require 'facebook_google_calendar_sync/google_calendar'
require 'facebook_google_calendar_sync/timezone'


module SharedCalendarNotifier
  extend self
  extend Logging
  extend Configuration

  DEFAULT_CONFIG = {
    :google_api_config_file => Pathname.new(ENV['HOME']) + '.google-api.yaml',
    :created_after_date => 1.day.ago,
    :log_level => :info,
    :mail_delivery_method => :sendmail,
    :bcc => nil
  }.freeze

  def run runtime_config = {}
    config = DEFAULT_CONFIG.merge runtime_config
    configure config
    send_notifications config
  end

  private

  def send_notifications config
    calendar = get_shared_calendar_by_name config[:shared_calendar_name]
    Time.zone = calendar.timezone
    notify_of_shared_events_created_after config[:created_after_date], calendar, config[:bcc]
  end

  def notify_of_shared_events_created_after created_after_date, calendar, bcc
    with_logging(created_after_date) do
      report_emails_for(calendar, created_after_date, bcc).each(&:send).size
    end
  end

  def with_logging created_after_date
    logger.info("Searching for events created or updated after #{created_after_date}")
    count = yield
    logger.info("No new events found") if count == 0
  end

  def report_emails_for calendar, created_after_date, bcc
    reports = reports_for calendar, created_after_date
    reports.collect { | report | ReportEmail.new report, bcc }
  end

  def reports_for calendar, created_after_date
    calendar.calendar_owner_email_addresses.collect do | email_address |
     ReportBuilder.build_report email_address, calendar.events, created_after_date
    end.find_all &:any_events?
  end

  def get_shared_calendar_by_name name
    unless calendar = FacebookGoogleCalendarSync::GoogleCalendar.find_calendar(name)
      raise "Could not find calendar with name \"#{name}\""
    end
    calendar
  end

end
