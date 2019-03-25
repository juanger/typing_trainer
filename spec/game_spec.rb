require 'typing_trainer'
require 'typing_trainer/game'

describe TypingTrainer::Game, '#play!' do

  before :each do
    game.stub(:prepare_screen)
    game.stub(:show_result)
  end

  let(:game) { TypingTrainer::Game.new(sentences: ["first", "second"], layout: :QWERTY) }

  it "shows each sentence" do
    game.should_receive(:show_sentence).exactly(2)
    game.should_receive(:clean_screen).exactly(2)
    game.should_receive(:show_result)
    game.play!
  end

  it "reads the characters" do
    game.should_receive(:get_character).and_return(*%w{f i r s t s e c o n d})
    game.play!
  end

  it "handles delete" do
    input = %w{f i r s x} + [[0x7F].pack('U')] + %w{t s e c o n d}

    game.should_receive(:get_character).and_return(*input)
    game.should_receive(:show_result)
    game.play!
  end

  it "handles delete at beginning" do
    input = [[0x7F].pack('U')]*3 + %w{f i r s t} + %w{s e c o n d}

    game.should_receive(:get_character).and_return(*input)
    game.should_receive(:show_result)
    game.play!
  end

end