class Game
  attr :args, :score, :player

  def initialize
    @score = 0
    @player = Player.new
  end
end