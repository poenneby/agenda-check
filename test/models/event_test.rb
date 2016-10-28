require 'test_helper'

class EventTest < ActiveSupport::TestCase

  test "one simple test example" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
    assert_equal ["9:30", "10:00", "11:30", "12:00"], availabilities[1][:slots]
    assert_equal Date.new(2014, 8, 16), availabilities[6][:date]
    assert_equal 7, availabilities.length
  end

  test "only openings" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 12:00"), ends_at: DateTime.parse("2014-08-04 14:00")

    availabilities = Event.availabilities DateTime.parse("2014-08-04")
    assert_equal Date.new(2014, 8, 4), availabilities[0][:date]
    assert_equal ["12:00", "12:30", "13:00", "13:30"], availabilities[0][:slots]
  end

  test "only appointments" do
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-04 12:00"), ends_at: DateTime.parse("2014-08-04 14:00")

    availabilities = Event.availabilities DateTime.parse("2014-08-04")
    assert_equal Date.new(2014, 8, 4), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
  end

  test "two weeks later" do
    Event.create kind: 'opening', starts_at: DateTime.parse('2014-08-04 09:30'), ends_at: DateTime.parse('2014-08-04 12:30'), weekly_recurring: true

    availabilities = Event.availabilities DateTime.parse("2014-08-18")
    assert_equal ['9:30', '10:00', '10:30', '11:00', '11:30', '12:00'], availabilities[0][:slots]
  end

  test "five weeks later" do
    Event.create kind: 'opening', starts_at: DateTime.parse('2014-08-04 09:30'), ends_at: DateTime.parse('2014-08-04 12:30'), weekly_recurring: true

    availabilities = Event.availabilities DateTime.parse("2014-09-08")
    assert_equal ['9:30', '10:00', '10:30', '11:00', '11:30', '12:00'], availabilities[0][:slots]
  end

  test "recurring years ago" do
    Event.create kind: 'opening', starts_at: DateTime.parse('2014-08-04 09:30'),
                       ends_at: DateTime.parse('2014-08-04 12:30'), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse('2014-08-09 11:00'),
                       ends_at: DateTime.parse('2014-08-09 11:30')
    Event.create kind: 'appointment', starts_at: DateTime.parse('2014-08-11 10:30'),
                       ends_at: DateTime.parse('2014-08-11 11:30')
    Event.create kind: 'opening', starts_at: DateTime.parse('2012-08-14 09:30'),
                       ends_at: DateTime.parse('2012-08-14 12:30'), weekly_recurring: true
    availabilities = Event.availabilities DateTime.parse('2014-08-18')

    assert_equal ['9:30', '10:00', '10:30', '11:00', '11:30', '12:00'], availabilities[1][:slots]
  end
end
