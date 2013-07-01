require 'shared_calendar_notifier'

module SharedCalendarNotifier
  class CLI
    def self.start config
      SharedCalendarNotifier.run config
    end
  end
end