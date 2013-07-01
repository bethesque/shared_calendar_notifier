require 'spec_helper'

describe SharedCalendarNotifier do

  let(:cut_off_time) { 60.minutes.ago }
  let(:creator_1) { double(Object, :email => 'test1@email.com') }
  let(:creator_2) { double(Object, :email => 'test2@email.com') }
  let(:all_event_creators) { [creator_1, creator_2] }
  let(:included_event) {double('Event',
    :created => cut_off_time,
    :creator => creator_2,
    :summary => "An event",
    :start => double('GoogleDate', :date_time => Time.new(2013, 01, 14, 9, 30) ),
    :location => "Somewhere")}
  let(:excluded_event) { double('Event', :created => cut_off_time - 1.second) }
  let(:events) { [ included_event, excluded_event ]}
  let(:calendar) { double(FacebookGoogleCalendarSync::GoogleCalendar, :timezone => 'Melbourne', :all_event_creators => all_event_creators, :events => events) }

  before do
    ENV['MAIL_SENDER'] = 'test@mailsender.com'
    FacebookGoogleCalendarSync::GoogleCalendar.stub(:find_calendar).and_return(calendar)
    #Why does this not work???
    #FacebookGoogleCalendarSync::GoogleCalendar.stub(:configure).and_yield(double("Config", :google_api_config_file= => nil))
    SharedCalendarNotifier.stub(:configure_client).with('some/path')
    Mail::TestMailer.deliveries.clear
    SharedCalendarNotifier.run :shared_calendar_name => "????", :created_after_date => cut_off_time, :google_api_config_file => 'some/path'
  end

  it { should have_sent_email.from('test@mailsender.com') }
  it { should have_sent_email.to('test1@email.com') }
  it { should have_sent_email.with_subject("An event - Mon 14 Jan 2013 9:30 am") }
  it { should have_sent_email.matching_body(/An event \- Mon 14 Jan 2013 9:30 am at Somewhere/) }
end