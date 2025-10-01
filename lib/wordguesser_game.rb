# lib/wordguesser_game.rb
class WordGuesserGame
    # Readers so the specs can access these
    attr_reader :word, :guesses, :wrong_guesses
  
    # Get a word from remote "random word" service
    def self.get_random_word
      require 'uri'
      require 'net/http'
      uri = URI('http://randomword.saasbook.info/RandomWord')
      Net::HTTP.new('randomword.saasbook.info').start do |http|
        return http.post(uri, "").body
      end
    end
  
    def initialize(word)
      @word = String(word)
      @guesses = ''        # correct, unique, lowercase letters guessed
      @wrong_guesses = ''  # incorrect, unique, lowercase letters guessed
    end
  
    # Process a single-letter guess.
    # Returns false if the letter was already guessed (correct or wrong).
    # Raises ArgumentError for nil/empty/non-letter or multi-char input.
    def guess(letter)
      # Validate input
      raise ArgumentError if letter.nil?
      s = letter.to_s
      raise ArgumentError if s.empty?
      raise ArgumentError unless s.length == 1 && s =~ /[A-Za-z]/
  
      ch = s.downcase
  
      # Already guessed?
      return false if @guesses.include?(ch) || @wrong_guesses.include?(ch)
  
      # Correct vs wrong
      if @word.downcase.include?(ch)
        @guesses << ch
      else
        @wrong_guesses << ch
      end
  
      true
    end
  
    # Reveal the word with dashes for unguessed letters
    def word_with_guesses
      @word.chars.map { |c|
        @guesses.include?(c.downcase) ? c : '-'
      }.join
    end
  
    # :win if all letters guessed, :lose after 7 wrong guesses, else :play
    def check_win_or_lose
      return :win  if word_with_guesses == @word
      return :lose if @wrong_guesses.length >= 7
      :play
    end
  end
  