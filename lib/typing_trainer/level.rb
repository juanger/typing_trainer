require "typing_trainer/keyboard_layout"

class TypingTrainer::Level
  attr_reader :sentences
  attr_reader :number
  attr_reader :letters
  
  def initialize(number: nil, letters: nil, sentences: [], filename: nil, layout: nil)
    throw "Missing layout!" unless layout
    throw "Missing sentences!" unless sentences.count > 0
    @number = number
    @letters = letters
    @sentences = sentences
    @layout_id = layout
    layouts = TypingTrainer::KeyboardLayout::LAYOUTS
    @layout = layouts[layout]
  end

  def header(width)
    if @number
      puts "Playing Level #{@number}"
      puts "-"*width
      puts
    elsif @letters && @letters.size == 1
      puts "New letter: #{@letters[0].upcase}"
      puts "-"*width
      puts
    end
  end

  def finger(letter)
    @layout::FINGER[letter.downcase]
  end

  # What is the next level if you know up to this letter?
  def next_level(letter)
    @layout::LETTER_PROGRESSION.index(letter.downcase) + 1
  end

  # What is the next letter to learn after beating this level?
  def next_letter(level)
    @layout::LETTER_PROGRESSION[level]
  end
end