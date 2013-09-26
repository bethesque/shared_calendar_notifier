require 'shared_calendar_notifier/logging'
require 'shared_calendar_notifier/version'
require 'shared_calendar_notifier/report'
require 'shared_calendar_notifier/report_email'
require 'facebook_google_calendar_sync/google_calendar'

module FacebookGoogleCalendarSync
  class GoogleCalendar

    def all_event_creators
      events.collect { | event | event.creator}.uniq(&:email)
    end

  end
end

module SharedCalendarNotifier
  extend self
  extend Logging

  DEFAULT_CONFIG = {
    :google_api_config_file => Pathname.new(ENV['HOME']) + '.google-api.yaml',
    :created_after_date => 1.day.ago,
    :log_level => :info,
    :mail_delivery_method => :sendmail
  }.freeze

  def run runtime_config = {}
    config = DEFAULT_CONFIG.merge runtime_config
    configure config
    calendar = get_shared_calendar_by_name config[:shared_calendar_name]
    unless calendar
      logger.error "Could not find calendar with name \"#{config[:shared_calendar_name]}\""
      exit 1
    end
    Time.zone = calendar.timezone
    notify config, calendar
  end

  private

  def notify config, calendar
    logger.debug("Searching for events created or updated after #{config[:created_after_date]}")
    reports = reports_for calendar, config[:created_after_date]
    report_emails = reports.collect { | report | ReportEmail.new report }
    report_emails.each(&:send)
    logger.debug("No new events found") if report_emails.empty?
  end

  def reports_for calendar, created_after_date
    calendar.all_event_creators.collect { | creator |
     ReportBuilder.build_report creator, calendar.events, created_after_date
    }.find_all &:any_events?
  end

  def get_shared_calendar_by_name name
    FacebookGoogleCalendarSync::GoogleCalendar.find_calendar name
  end

  def self.configure config
    check_environment_config
    configure_logger config[:log_level]
    configure_mailer config[:mail_delivery_method]
    configure_client config[:google_api_config_file]
  end

  def self.configure_mailer delivery_method
    Mail.defaults do
      delivery_method delivery_method
    end
    if delivery_method == :test
      logger.debug("Dry run - emails won't be delivered")
    end
  end

  def self.configure_logger log_level
    logger.level = Logger.const_get(log_level.to_s.upcase)
  end

  def check_environment_config
    raise "Please set the email sender in your environment variables eg. export MAIL_SENDER=someone@email.com" unless ENV['MAIL_SENDER']
  end

  def configure_client google_api_config_file
    FacebookGoogleCalendarSync::GoogleCalendarClient.configure do | conf |
      conf.google_api_config_file = google_api_config_file
    end
  end
end
