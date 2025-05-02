=begin
7:59 - 8:11 : 12 minutes


input
  - string with time : hh:mm where hh is hours, mm is minutes
output
  - after_midnight:  number of minutes after midnight
  - before_midnight:  number of minutes before midnight
rules
  - implicit:  all minutes should be less than 1440 (24 hrs * 60 mins = 1440 mins in a day)

algorithm
  - convert string to integers:  hh, mm

  - (hh * 60) + mm = total minutes
    - dividing by 1440 (minutes / day) will correct this to only show 0 and not 1440

  - after midnight:  return this number directly
  - before midnight:  return 1440 - subtract this number

=end

MINUTES_IN_DAY = 24 * 60

def after_midnight(string)
  hrs,min = string.split(":")
  hh = hrs.to_i
  mm = min.to_i
  (hh * 60 + mm) % MINUTES_IN_DAY
end

def before_midnight(string)
  ( MINUTES_IN_DAY - after_midnight(string) ) % MINUTES_IN_DAY
end

# test cases
p after_midnight('00:00') == 0
p before_midnight('00:00') == 0
p after_midnight('12:34') == 754
p before_midnight('12:34') == 686
p after_midnight('24:00') == 0
p before_midnight('24:00') == 0

