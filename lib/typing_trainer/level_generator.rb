require 'contemporary_words'
require "typing_trainer/level"
require "typing_trainer/keyboard_layout"

class TypingTrainer::LevelGenerator

  SENCENCES_PER_LEVEL = 3
  WORDS_PER_SENTENCE = 8

  def self.generate(level: nil, letters: nil, layout: nil)
    throw "You need to specify a layout" unless layout
    throw "No level or letters were provided to generate a Game level :(" unless level || letters
    
    layouts = TypingTrainer::KeyboardLayout::LAYOUTS

    layout_letters = layouts[layout]::LETTER_PROGRESSION
    if letters
      letters = letters.join('').downcase
    end
    letters ||= layout_letters.slice(0, level)
    sentences = self.new(letters).generate_sentences(SENCENCES_PER_LEVEL)
    TypingTrainer::Level.new(number: level, letters: letters, sentences: sentences, layout: layout)
  end

  def initialize(letters)
    @letters = letters.split(//)
    @level_pattern = /^[#{letters}]+$/
    @words = initialize_words
  end

  def initialize_words
    words = ContemporaryWords.all.filter { |word| @level_pattern.match?(word) }
    while words.size < WORDS_PER_SENTENCE
      words << self.generate_word
    end
    words
  end

  def generate_sentences(count)
    sentences = []
    count.times {
      sentences << @words.sample(WORDS_PER_SENTENCE).join(' ') + ' '
    }
    sentences
  end

  def generate_word
    (@letters * 10).sample(rand(5) + 1).join('')
  end

end