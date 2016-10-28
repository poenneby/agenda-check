class Event < ApplicationRecord
  def self.availabilities in_date
    openings = Event.where('kind = "opening"')
    recurringOpenings = openings + openings.reduce([]) {
      |acc, event|
      days = (in_date - DateTime.parse(event.starts_at.strftime("%Y-%m-%d"))).to_i
      weeks = (days > 7 ? days / 7 : days) + 2
      (event.weekly_recurring === true) ? acc + recurring_events([event], weeks) : acc
    }

    openingSlotsPerDay = recurringOpenings.map {
      |event|
      {
        slotDate: DateTime.parse(event.starts_at.strftime("%Y-%m-%d")),
        slots: [event.starts_at].tap { |array| array << array.last + 30.minutes while array.last + 30.minutes < event.ends_at }
      }
    }

    appointments = Event.where('kind = "appointment"')
    appointmentSlotsPerDay = appointments.map {
      |event|
      {
        slotDate: DateTime.parse(event.starts_at.strftime("%Y-%m-%d")),
        slots: [event.starts_at].tap { |array| array << array.last + 30.minutes while array.last + 30.minutes < event.ends_at }
      }
    }

    (in_date..in_date + 6).map {
      |date|
      openSlotsDay = openingSlotsPerDay.select {
        |day| day[:slotDate] === date
      }.first

      appointmentSlotsDay = appointmentSlotsPerDay.select {
        |day| day[:slotDate] === date
      }.first

      availableSlotDates = (appointmentSlotsDay && openSlotsDay) ? openSlotsDay[:slots].reject{|slot| appointmentSlotsDay[:slots].include? slot} : (openSlotsDay ? openSlotsDay[:slots] : [])

      {
        date: date,
        slots: availableSlotDates.map { |slotDate| slotDate.strftime("%-H:%M") }
      }
    }
  end

  private
  def self.recurring_events(in_events, weeks)
    return in_events if in_events.length == weeks
    return recurring_events(in_events +
      [Event.new do |e|
        e.kind = in_events.last.kind
        e.starts_at = in_events.last.starts_at + 7.days
        e.ends_at = in_events.last.ends_at + 7.days
      end],
      weeks
    )
  end
end
