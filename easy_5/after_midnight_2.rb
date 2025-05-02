=begin

data structure
  - 

algorithm
  - convert time in string into 2 numbers : hh and mm (integers)
  - if hh == 0 or 24 then it contributes no minutes towards total minutes
    - otherwise, total minutes = hh * MIN_PER_HOUR  +  mm
  - if before_midnight, answer is 1440 - total minutes
  - if after_midnight, answer is total minutes

=end

MIN_PER_HOUR = 60
HOUR_PER_DAY = 24
MIN_PER_DAY = MIN_PER_HOUR * HOUR_PER_DAY


def before_midnight(string)
  total_min = 1440
  hh, mm = string.split(":")
  # p "#{hh} #{mm}"
  total_min -= hh.to_i * MIN_PER_HOUR
  total_min -= 24 * MIN_PER_HOUR if hh.to_i == 0
  # p total_min -= mm.to_i
  total_min -= mm.to_i
end

def after_midnight(string)
  total_min = 0
  hh, mm = string.split(":")
  # p "#{hh} #{mm}"
  total_min = hh.to_i * MIN_PER_HOUR if hh.to_i != 0 && hh.to_i != 24
  # p total_min += mm.to_i
  total_min += mm.to_i
end


# test cases
p after_midnight('00:00') == 0
p before_midnight('00:00') == 0
p after_midnight('12:34') == 754
p before_midnight('12:34') == 686
p after_midnight('24:00') == 0
p before_midnight('24:00') == 0
