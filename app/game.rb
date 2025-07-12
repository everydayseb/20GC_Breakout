class Game
  attr :args, :player

  def initialize
    @player = Player.new
  end
end