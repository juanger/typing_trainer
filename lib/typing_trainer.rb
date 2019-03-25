require "typing_trainer/version"

require "highline"
require "highline/system_extensions"
require "stty"
require "ffi"
require "termios"
require "typing_trainer/game"

module TypingTrainer

  COLORS = HighLine::ColorScheme.new do |cs|
    cs[:error]         = [ :bold, :white, :on_red ]
    cs[:correct]       = [ :bold, :white, :on_green ]
  end

  HighLine::Style.new(:name=>:return, :builtin=>true, :code=>"\r")
  HighLine::Style.new(:name=>:newline, :builtin=>true, :code=>"\n")
  HighLine::Style.new(:name=>:up, :builtin=>true, :code=>"\e[A")
  HighLine::Style.new(:name=>:down, :builtin=>true, :code=>"\e[B")
  HighLine::Style.new(:name=>:forward, :builtin=>true, :code=>"\e[C")
  HighLine::Style.new(:name=>:backward, :builtin=>true, :code=>"\e[D")

  HighLine.color_scheme = COLORS

  def self.run(options)
    @game = Game.new(options)

    @game.play!
  end

end