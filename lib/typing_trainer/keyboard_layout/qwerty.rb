#require "typing_trainer/keyboard_layout"

module TypingTrainer::KeyboardLayout
  class Qwerty
    LETTER_PROGRESSION = "asdfjklghruvmbntyeiwoqpxz"

    FINGER = {
      'a' => :LEFT_P,
      'b' => :LEFT_I,
      'c' => :LEFT_M,
      'd' => :LEFT_M,
      'e' => :LEFT_M,
      'f' => :LEFT_I,
      'g' => :LEFT_I,
      'h' => :RIGHT_I,
      'i' => :RIGHT_M,
      'j' => :RIGHT_I,
      'k' => :RIGHT_M,
      'l' => :RIGHT_R,
      'm' => :RIGHT_I,
      'n' => :RIGHT_I,
      'o' => :RIGHT_R,
      'p' => :RIGHT_P,
      'q' => :LEFT_P,
      'r' => :LEFT_I,
      's' => :LEFT_R,
      't' => :LEFT_I,
      'u' => :RIGHT_I,
      'v' => :LEFT_I,
      'w' => :LEFT_R,
      'x' => :LEFT_R,
      'y' => :RIGHT_I,
      'z' => :LEFT_P,
      ' ' => :LEFT_T
    }
  end
end