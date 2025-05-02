=begin
input
  - integer (+ve or -ve) : +ve is minutes after midnight
                         : -ve is minutes before midnight

output
  - string : hh:mm format of time of day

assumptions / constraints
  - cannot use Date or Time classes

data structure
  - work with integers, use interpolation to create final string

algorithm
  - eliminate 'days' from minutes (i.e., 1440 minutes in a day) - just take remainder after dividing by 1440
  - can determine # of hours by dividing minutes (of day) by 60, the remainder is the number of minutes
  - if integer is +ve : can add hh:mm to 00:00
  - if integer is -ve : can subtract hh:mm from 24:60

=end

def display_num(num)
  if num < 10
    "0"+num.to_s
  else
    num.to_s
  end
end

def time_of_day(num)
  mins_in_day = num % 1440
  # p mins_in_day
  hh, mm = mins_in_day.divmod(60)
  # p "#{display_num(hh)}:#{display_num(mm)}"
  "#{display_num(hh)}:#{display_num(mm)}"
end

# test cases
p time_of_day(0) == "00:00"
p time_of_day(-3) == "23:57"
p time_of_day(35) == "00:35"
p time_of_day(-1437) == "00:03"
p time_of_day(3000) == "02:00"
p time_of_day(800) == "13:20"
p time_of_day(-4231) == "01:29"
