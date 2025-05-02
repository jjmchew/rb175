=begin
6:21 - 6:43

input
  - an integer (positive or negative) : represents minutes after or before midnight (respectively)
output
  - a string : hh:mm format (always 2 digits) represents hours and minutes as a time
rules
  - input integer can be more minutes than 1 day - since time is output, no need to track how many days after / before midnight

algorithm
  - need to 'convert' minutes to represent only 1 day (i.e., within 24 hrs)
      - if number is -ve, add 1440 until positive > can use mins % 1440
      - if number is +ve, take the remainder of given minutes divided by 1440 > can also use mins % 1440
  - can then divide the numbers of minute in 1 day by 60 to get the hh, and then the remainder is mm > can use divmod

  - ensure output is in string format and hh and mm are 2 digits (with leading 0, if necessary)

Notes
  - there are 60 minutes in 1 hr;  60 * 24 = 1440 mins / day

Examples
  given   converted minutes (1 day)
  -3      1437
  -1437   3
  3000    120
  -4231   89

=end
MINUTES_IN_DAY = 1440 # 24 * 60

def time_of_day(minutes)

  mins = minutes % MINUTES_IN_DAY
  hh, mm = mins.divmod(60)
  format('%02d:%02d',hh,mm)
end

# test cases
p time_of_day(0) == "00:00"
p time_of_day(-3) == "23:57"
p time_of_day(35) == "00:35"
p time_of_day(-1437) == "00:03"
p time_of_day(3000) == "02:00"
p time_of_day(800) == "13:20"
p time_of_day(-4231) == "01:29"
