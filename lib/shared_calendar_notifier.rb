require 'shared_calendar_notifier/version'
require 'shared_calendar_notifier/report'
require 'shared_calendar_notifier/report_email'
require 'facebook_google_calendar_sync/google_calendar'

Mail.defaults do
  delivery_method :sendmail
end

module FacebookGoogleCalendarSync
  class GoogleCalendar

    def all_event_creators
      events.collect { | event | event.creator}.uniq(&:email)
    end

  end
end

module SharedCalendarNotifier
  extend self

  DEFAULT_CONFIG = {:google_api_config_file => Pathname.new(ENV['HOME']) + '.google-api.yaml', :created_after_date => 1.day.ago}

  def run runtime_config = {}
    check_environment_config
    config = DEFAULT_CONFIG.merge runtime_config
    configure_client config[:google_api_config_file]
    calendar = get_shared_calendar_by_name config[:shared_calendar_name]
    Time.zone = calendar.timezone
    notify config, calendar
  end

  private

  def check_environment_config
    raise "Please set the email sender in your environment variables" unless ENV['MAIL_SENDER']
  end

  def notify config, calendar
    reports = reports_for calendar, config[:created_after_date]
    report_emails = reports.collect { | report | ReportEmail.new report }
    report_emails.each(&:send)
  end

  def reports_for calendar, created_after_date
    calendar.all_event_creators.collect { | creator |
     ReportBuilder.build_report creator, calendar.events, created_after_date
    }.find_all &:any_events?
  end

  def get_shared_calendar_by_name name
    FacebookGoogleCalendarSync::GoogleCalendar.find_calendar name
  end

  def configure_client google_api_config_file
    FacebookGoogleCalendarSync::GoogleCalendarClient.configure do | conf |
      conf.google_api_config_file = google_api_config_file
    end
  end
end
