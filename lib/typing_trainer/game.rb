require "typing_trainer/level_generator"
require "typing_trainer/level"

# 
# Game
# 
# Manages the game and internal state, checks if input is correct, prints information and handles
# screen cleanup
#
class TypingTrainer::Game
  include HighLine::SystemExtensions

  # Creates a new game
  # 
  # @param [String] letter only words with that letter are shown and finger is shown.
  # @param [Integer] level the level of the game, this is used to generate sentences. Overrides `letter`
  # @param [String] file a file path to a text file for the game, overrides `level`
  # @param [Array<String>] sentences the list of sentences to use for this game
  # @param [Bool] advanced whether to show the finger hints or not
  # @param [Symbol] layout the name of the layout to use. See TypingTrainer::KeyboardLayout
  def initialize(level: nil, file: nil, sentences: nil, layout: :QWERTY, debug: false, advanced: false, letter: nil)
    @layout = layout
    @level_number = level
    if !level && !letter
      @level_number = 1
    end
    @file = file
    @debug = debug
    @advanced = advanced
    @override_sentences = sentences
    @introduce_letter = letter
    @h = HighLine.new
  end

  def play!
    @total_errors = 0
    @errors = {}
    @level = generate_level
    @sentences = get_sentences
    prepare_screen
    before = Time.now
    @sentences.each do |sentence|
      print_level_header
      show_sentence(sentence)
      clean_screen
    end
    show_result(before)
  rescue SystemExit, Interrupt
    reset_terminal
  rescue  Exception => e
    reset_terminal
    raise e
  end

private

  def reset_terminal
    clean_screen
    @h.restore_mode
    puts "Thank you for playing."
    puts "Good bye!"
    print :clear
    print :erase_line
  end

  def generate_level
    @level = if @override_sentences
      TypingTrainer::Level.new(sentences: @override_sentences, layout: @layout)
    elsif @file
      TypingTrainer::Level.new(
        sentences: open(@file).readlines.map {|l| l.strip!; l == "" ? nil : l;}.compact,
        filename: @file,
        layout: @layout
      )
    elsif @introduce_letter
      TypingTrainer::LevelGenerator.generate(letters: [@introduce_letter], layout: @layout)
    else
      TypingTrainer::LevelGenerator.generate(level: @level_number, layout: @layout)
    end    
  end

  def get_sentences
    @level.sentences
  end

  def get_character
    @h.get_character
  end

  def show_sentence(sentence)
    @cursor = 0
    original = sentence
    @typed = ""

    print original
    print :newline
    print_hands(finger: @level.finger(original[@cursor])) if @introduce_letter
    $stdout.flush

    while c = get_character.chr do
      # puts "CHAR: #{c}"
      typed_error = false
      case c
      when "\x7F"           # backspace
        delete_char
        print_hands(finger: @level.finger(original[@cursor]))
        @cursor.times do
          print :forward
        end
        next
      when original[@cursor] # good
        print c, :correct
      else                  # error
        log_error(c)
        typed_error = true
      end


      @typed += c
      @cursor += 1
      finished = original == @typed
      should_show_hands = !finished && original[@cursor] && (@introduce_letter || typed_error)
      if (should_show_hands)
        print_hands(finger: @level.finger(original[@cursor]))
        @cursor.times do
          print :forward
        end
      elsif !finished
        hide_hands
        @cursor.times do
          print :forward
        end
      end

      typed_error = false

      if original == @typed
        break
      end
    end
  end

  # Prints hands with finger hints
  def print_hands(finger: nil)
    print :newline
    print HANDS
    (HANDS.lines.count + 1).times do
      print :up
    end
    print_finger(finger)
  end

  # Erases the lines showing finger hints
  def hide_hands
    print :newline
    (HANDS.lines.count + 1).times do
      print :erase_line
      puts
    end
    (HANDS.lines.count + 1).times do
      print :up
    end
    print :up
  end

  # Finds which finger has to be highlighted and prints
  # a white block inside it.
  def print_finger(finger)
    finger_character = '█'
    finger_coords = {
      LEFT_P: [2,1],
      LEFT_R: [1,3],
      LEFT_M: [1,5],
      LEFT_I: [1,7],
      LEFT_T: [4,10],
      RIGHT_P: [2,28],
      RIGHT_R: [1,26],
      RIGHT_M: [1,24],
      RIGHT_I: [1,22],
      RIGHT_T: [4,19]
    }

    coords = finger_coords[finger]
    if (coords)
      print :down
      coords[0].times { print :down }
      coords[1].times { print :forward }
      print finger_character
      print :backward
      coords[1].times { print :backward }
      coords[0].times { print :up }
      print :up
    end
  end

  # Print results of last played game.
  def show_result(started_at)
    @h.restore_mode
    total_chars = @sentences.join.size
    accuracy = "#{((total_chars - @total_errors) * 100.0 / total_chars).round(2)}%"
    elapsed_minutes = (Time.now - started_at)/60
    total_words = @sentences.join.split(' ').size
    # wpm = "#{total_words/elapsed_minutes.to_f} WPM"
    ccpm = "#{((total_chars)/elapsed_minutes.to_f).floor/5} WPM / #{((total_chars)/elapsed_minutes.to_f).floor} CPM"

    print "These are your results:\n", :bold
    print "Total time: #{elapsed_minutes} minutes\n", :bold
    print "Character count: #{total_chars}\n", :bold
    print 'Speed: ', :blue
    print ccpm, :bold
    print ' '
    print 'Accuracy: ', :green
    print accuracy, :bold
    print ' '
    print 'Errors: ', :red
    print "#{@total_errors}/#{total_chars}", :bold
    if @h.ask("\n\nDo you want to play again? [y,n]", ["y", "n"]) == "y"
      # The logic ahead allows us to support starting from a letter or a level indistictively and
      # continue with the next levels and letters as expected
      if @introduce_letter
        @level_number = @level.next_level(@introduce_letter)
        if @level_number == 1
          # If they only know one letter, don't make them repeat it. Introduce one more instead
          @introduce_letter = @level.next_letter(1)
        else
          @introduce_letter = nil
        end
      elsif @level_number
        @introduce_letter = @level.next_letter(@level_number)
      end
      play!
    end
  end

  # Our own print to override the system one.
  # This uses HighLine to output special characters
  # If the parameter is a symbol, it will use
  # HighLine.Style() and use its code
  def print(str_or_sym, color = :none)
    s = case str_or_sym
    when String
      @h.color(str_or_sym, color)
    when Symbol
      HighLine.Style(str_or_sym).code
    end
    $stdout.print(s)
  end

  # Ensures the screen has all the lines that the terminal has
  # to move freely without needing to create more lines.
  def prepare_screen
    # Ensure we restore mode bedore setting to no_echo
    # otherwise we lose context and cannot go back
    @h.restore_mode rescue
    print :erase_line
    @h.output_rows.times do
      print :newline
    end
    @h.output_rows.times do
      print :up
    end
    @h.raw_no_echo_mode
  end

  # Uses the level information to print
  # a header while a game is underway.
  def print_level_header
    print @level.header(@h.output_cols)
    if @debug
      puts({
        layout: @layout,
        level: @level_number,
        letter: @introduce_letter,
        advanced: @advanced,
        cursor: @cursor
      }).inspect
    end
  end

  # Uses a clear screen escape sequence
  # and prepares the screen
  def clean_screen
    print "\e[2J"
    prepare_screen
  end

  # Deletes a character in the input "bar"
  def delete_char
    print :backward
    print :erase_char
    @cursor -= 1 if @cursor > 0
    @typed = @typed[0..-2] if @typed.size > 0
  end

  # Changes the color of the input "bar" to show
  # the user didn't type the right character
  def log_error(c)
    print c, :error
    @total_errors += 1
    @errors[c] ||= 0
    @errors[c] += 1
  end

  # ASCII Hands. We need to escape \ because it is
  # a special character for strings.
  HANDS = <<~HANDS
         _.-._              _.-._
       _| | | |            | | | |_
      | | | | |            | | | | |
      | | | | | /\\      /\\ | | | | |
      |       |/ /      \\ \\|       |
      |       / /        \\ \\       |
      |        /          \\        |
       \\      /            \\      /
        |    |              |    |
  HANDS

end
