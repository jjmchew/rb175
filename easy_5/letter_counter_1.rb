

def word_sizes(string)
  count = {}

  string.split(" ").each do |word|
    count[word.length] += 1 if count[word.length]
    count[word.length] = 1 unless count[word.length]
  end

  count
end

# test cases
p word_sizes('Four score and seven.') == { 3 => 1, 4 => 1, 5 => 1, 6 => 1 }
p word_sizes('Hey diddle diddle, the cat and the fiddle!') == { 3 => 5, 6 => 1, 7 => 2 }
p word_sizes("What's up doc?") == { 6 => 1, 2 => 1, 4 => 1 }
p word_sizes('') == {}