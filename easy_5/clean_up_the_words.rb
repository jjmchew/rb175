
def cleanup(string)
  string.gsub(/[^a-z]+/,' ')
end

# test cases
p cleanup("---what's my +*& line?") == ' what s my line '