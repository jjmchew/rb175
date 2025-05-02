=begin
algorithm
  - turn each string into an array of words
  - iterate across each word (for transformation):
      - convert each word into an array of characters
      - track 'non-duplicated characters' in a new array
      - iterate across each character
          - check if the current character is NOT the same as the last character in the 'tracking array'
            - if not the same:  add current character to tracking array
            - if the same:  do nothing
      - recombine tracking array into a word
      - return this new word to update the array of words

=end

def crunch(string)
  words = string.split(" ")
  words.map! do |word|
    new_word = []
    word.chars.each do |char|
      new_word << char if char != new_word.last
    end
    new_word.join("")
  end
  words.join(" ")
end

# test cases
p crunch('ddaaiillyy ddoouubbllee') == 'daily double'
p crunch('4444abcabccba') == '4abcabcba'
p crunch('ggggggggggggggg') == 'g'
p crunch('a') == 'a'
p crunch('') == ''