=begin

algorithm
  - convert string to array of char
  - iterate across each element of array:
      - convert each char to ascii value using String#ord
      - add that value to a running total
=end

def ascii_value(string)
  sum = 0
  string.chars.each do |char|
    sum += char.ord
  end
  sum
end

# test cases
p ascii_value('Four score') == 984
p ascii_value('Launch School') == 1251
p ascii_value('a') == 97
p ascii_value('') == 0
