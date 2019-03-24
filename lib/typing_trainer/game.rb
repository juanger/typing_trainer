class TypingTrainer::Game
  include HighLine::SystemExtensions

  # sentences - An enumerable of sentences
  def initialize(sentences)
    @h = HighLine.new
    @sentences = sentences
    @total_errors = 0
    @errors = {}
    # @h.wrap_at = 80
    # @h.page_at = :auto
  end

  def play!
    prepare_screen
    before = Time.now
    @sentences.each do |sentence|
      show_sentence(sentence)
      clean_screen
    end
    show_result(before)
  end

private

  def get_character
    @h.get_character
  end

  def show_sentence(sentence)
    @cursor = 0
    original = sentence
    @typed = ""

    print original
    print :newline
    $stdout.flush

    while c = get_character.chr do
      # puts "CHAR: #{c}"
      case c
      when "\x7F"           # backspace
        delete_char
        next
      when original[@cursor] # good
        print c, :correct
      when "\n"
        @reset = true
      else                  # error
        log_error(c)
      end

      unless @reset
        @typed += c
        @cursor += 1
      end

      @reset = false

      if original == @typed
        break
      end
    end
  end

  def show_result(started_at)
    @h.restore_mode
    total_chars = @sentences.join.size
    accuracy = "#{((total_chars - @total_errors) * 100.0 / total_chars).round(2)}%"
    elapsed_minutes = (Time.now - started_at)/60
    total_words = @sentences.join.split(' ').size
    # wpm = "#{total_words/elapsed_minutes.to_f} WPM"
    ccpm = "#{((total_chars)/elapsed_minutes.to_f).floor/5} WPM / #{((total_chars)/elapsed_minutes.to_f).floor} CPM"

    print "This are your results:\n", :bold
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
      play!
    end
  end

  def print(str_or_sym, color = :none)
    s = case str_or_sym
    when String
      @h.color(str_or_sym, color)
    when Symbol
      HighLine.Style(str_or_sym).code
    end
    $stdout.print(s)
  end

  def prepare_screen
    @h.output_rows.times do
      print :newline
    end
    @h.output_rows.times do
      print :up
    end
    @h.raw_no_echo_mode
  end

  def clean_screen
    print :return
    print :erase_line
    print :up
    print :erase_line
  end

  def delete_char
    print :backward
    print :erase_char
    @cursor -= 1 if @cursor > 0
    @typed = @typed[0..-2] if @typed.size > 0
  end

  def log_error(c)
    print c, :error
    @total_errors += 1
    @errors[c] ||= 0
    @errors[c] += 1
  end

end
