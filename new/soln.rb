MINUTES_IN_DAY = 1440

def time_of_day(minutes)
  normalized_minutes = minutes % MINUTES_IN_DAY

  hh, mm = normalized_minutes.divmod(60)
  "%02d:%02d" % [ hh, mm ]
end

puts time_of_day(3)
puts time_of_day(-1437)
puts time_of_day(59)
puts time_of_day(62)
