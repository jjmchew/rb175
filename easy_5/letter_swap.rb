
def swap(string)
  words = string.split(" ")
  words.map! do |word|
    tmp = word[0]
    word[0] = word[-1]
    word[-1] = tmp
    word
  end
  words.join(" ")
end

# test cases
p swap('Oh what a wonderful day it is') == 'hO thaw a londerfuw yad ti si'
p swap('Abcde') == 'ebcdA'
p swap('a') == 'a'