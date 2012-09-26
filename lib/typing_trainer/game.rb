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
    @sentences.each do |sentence|
      show_sentence(sentence)
      clean_screen
    end
    show_result
  end

private

  def show_sentence(sentence)
    @cursor = 0
    original = sentence
    @typed = ""

    print original
    print :newline
    $stdout.flush

    while c = get_character.chr do
      case c
      when "\x7F"           # backspace
        delete_char
        next
      when original[@cursor] # good
        print c, :green
      else                  # error
        log_error(c)
      end

      @typed += c
      @cursor += 1

      if original == @typed
        break
      end
    end
  end

  def show_result
    total_chars = @sentences.join.size
    accuracy = "#{((total_chars - @total_errors) * 100.0 / total_chars).round(2)}%"

    print "This are your results:\n", :bold
    print "Accuracy: ", :green
    print accuracy, :bold
    print " "
    print "Errors: ", :red
    print "#{@total_errors}/#{total_chars}", :bold
    if @h.ask("\n\nDo you want to play again? [y,n]", ["y", "n"]) == "Y"
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
    @typed = @typed[0..-2]
  end

  def log_error(c)
    print c, :error
    @total_errors += 1
    @errors[c] ||= 0
    @errors[c] += 1
  end

end
