require 'typing_trainer'
require 'typing_trainer/level_generator'

describe TypingTrainer::LevelGenerator, '#generate' do

  it "should generate 5 sentences per level" do
    level = TypingTrainer::LevelGenerator.generate(level: 1, layout: :QWERTY);
    level.sentences.size.should be 4
  end

  it "should generate 8 words per sentence" do
    level = TypingTrainer::LevelGenerator.generate(level: 1, layout: :QWERTY);
    level.sentences[0].split(' ').size.should be 8
  end

end