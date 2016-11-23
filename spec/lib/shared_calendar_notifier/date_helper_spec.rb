require 'spec_helper'
require 'shared_calendar_notifier/date_helper'

module SharedCalendarNotifier

  describe DateHelper do
    include DateHelper

    describe "days_away_in_words" do
      let(:from_date) { Date.new(2016, 1, 1) }

      context "when the number of days is 0" do
        it "returns 'Today'" do
          expect(days_away_in_words(0, from_date)).to eq "Today"
        end
      end

      context "when the number of days away is less than 7" do
        it "returns 'This XXXday'" do
          expect(days_away_in_words(6, from_date)).to eq "This Thursday"
        end
      end

      context "when the number of days away is 7" do
        it "returns 'XXXday week'" do
          expect(days_away_in_words(7, from_date)).to eq "Friday week"
        end
      end

      context "when the number of days away is less than 14" do
        it "returns 'XXXday week'" do
          expect(days_away_in_words(13, from_date)).to eq "Thursday week"
        end
      end

      context "when the number of days away is 14" do
        it "returns 'Friday in 2 weeks'" do
          expect(days_away_in_words(14, from_date)).to eq "Friday in 2 weeks"
        end
      end

      context "when the number of days is negative" do
        it "returns 'In the past'" do
          expect(days_away_in_words(-1, from_date)).to eq "In the past"
        end
      end
    end
  end
end
