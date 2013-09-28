module FacebookGoogleCalendarSync
  class GoogleCalendar

    def all_event_creators
      events.collect { | event | event.creator}.uniq(&:email)
    end

  end
end