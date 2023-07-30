#!/usr/bin/env ruby

require 'active_support/inflector'

words = ARGV[0].downcase
hints = ARGV[1].split

def get_unique_chars(phrase)
  %x|echo #{phrase} \| grep -o -E '[[:alnum:]]' \| sort -u \| tr -d '\n'|
end

def get_char_occurences(phrase)
  uniques_chars = get_unique_chars(phrase).split('')
  occurences = {}
  uniques_chars.each do |char|
    occurences[char] = phrase.count(char)
  end

  occurences
end

def get_remaining_occurences(initial_occurences, used_occurences)
  remaining_occurences = initial_occurences.clone

  used_occurences.each do |key, value|
    remaining_occurences[key] = initial_occurences[key] - used_occurences[key] 
  end

  remaining_occurences
end

def valid_remaining_occurences?(occurences)
  not occurences.any? { |_, value|  value < 0 }
end

def get_remaining_chars(occurences)
  remaining_chars = ""
  occurences.each do |key, value|
    remaining_chars += key if value > 0
  end

  remaining_chars
end

def compute_anagrams(initial_occurences, hints, solution)
  if not valid_remaining_occurences?(initial_occurences)
    return
  end

  if hints.empty? then
      puts "#{solution}\n"
      return
  end

  hint = hints.shift

  pattern="[#{get_remaining_chars(initial_occurences)}]"
  regex="^#{hint.gsub('*', pattern)}\\s$"
  matching_words = %x|grep -E "#{regex}" ./dictionnaire|.split

  matching_words.each do |word|
    used_occurences = get_char_occurences(word.parameterize)
    remaining_occurences = get_remaining_occurences(initial_occurences, used_occurences)
    compute_anagrams(remaining_occurences, hints.clone, "#{solution} #{word}")
  end
end

compute_anagrams(get_char_occurences(words), hints, "")
