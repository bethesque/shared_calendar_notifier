require 'shared_calendar_notifier/logging'

module SharedCalendarNotifier
  module Configuration

    extend Logging

    def configure config
      logger.debug "Running with configuration #{config}"
      check_environment_config
      raise "Please provider a calendar name" unless config[:shared_calendar_name]
      configure_logger config[:log_level]
      configure_mailer config[:mail_delivery_method], config[:mail_delivery_options]
      configure_client config[:google_api_config_file]
    end

    def configure_mailer delivery_method, delivery_options
      Mail.defaults do
        delivery_method delivery_method, delivery_options
      end
      if delivery_method == :test
        logger.info("Dry run - emails won't be delivered")
      end
    end

    def configure_logger log_level
      logger.level = Logger.const_get(log_level.to_s.upcase)
      FacebookGoogleCalendarSync::GoogleCalendar.logger.level = logger.level
    end

    def check_environment_config
      raise "Please set the email user in your environment variables eg. export MAIL_SENDER=someone@email.com" unless ENV['MAIL_SENDER']
      raise "Please set the email user in your environment variables eg. export SMTP_USERNAME=someone@email.com" unless ENV['SMTP_USERNAME']
      raise "Please set the email user password in your environment variables eg. export SMTP_PASSWORD=password" unless ENV['SMTP_PASSWORD']
    end

    def configure_client google_api_config_file
      FacebookGoogleCalendarSync::GoogleCalendarClient.configure do | conf |
        conf.google_api_config_file = google_api_config_file
      end
    end
  end

end