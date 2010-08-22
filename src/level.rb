class Level < GameState
  trait :timer
  attr_reader :player, :game_object_map, :floor_y, :grid

  def initialize
    super
    self.input = { :esc => :exit, :e => :edit }
    @floor_y = $window.height + 2 - 32*2
    @player = Player.create(:x => 40, :y => @floor_y)
  end
  
  def setup    
    @grid = [8, 8]
    @file = File.join(ROOT, "#{self.class.to_s.downcase}.yml")
    load_game_objects(:file => @file)
    @game_object_map = GameObjectMap.new(:game_objects => Block.all + Grass.all, :grid => @grid)
    @energy_font = Font.new($window, Gosu::default_font_name, 20)    
  end
  
  def edit
    push_game_state GameStates::Edit.new(:grid => @grid, :except => [Player], :file => @file, :debug => true)
  end
  
  def draw
    fill_gradient(:from => Color::BLUE, :to => Color::CYAN)
    super
  end
  
  def update
    super
    
    #@player.each_collision(Enemy) do |player, enemy|
    #  unless enemy.grabbed? || enemy.thrown
    #    player.hit_by(enemy)
    #    enemy.hit_by(player)
    #  end
    #end
    
    Enemy.each_collision(Block) do |enemy, block|
      if enemy.thrown
        enemy.destroy
        block.hit_by(enemy)
      end
    end
    
    @energy_font.draw("Energy: #{$window.energy}", 10, 10, 10)
    $window.caption = "Gnorf (is breaking an entrence). LD#18 entry by http://ippa.se/gaming - [#{@player.x}/#{@player.y}]"
  end
  
end

class Level1 < Level
  def setup
    super
    #every(1000) { Smokepuff.create(:x => $window.width/2, :y => $window.height/2) }
    Balloon.create(:x => $window.width - 150, :y => 200)
    Balloon.create(:x => 50, :y => 150)
    Knight.create(:x => $window.width - 500, :y => 550)
    every(10000) { Horse.create(:x => $window.width - 100, :y => 550) }
    every(5000) { Knight.create(:x => $window.width - 50, :y => 550) }
  end  
end

class Level2 < Level
end
class Level3 < Level
end
class Level4 < Level
end
class Level5 < Level
end
class Level6 < Level
end
class Level7 < Level
end
class Level8 < Level
end
class Level9 < Level
end
class Level10 < Level
end

class MenuState < GameState
  def setup
    SimpleMenu.create(
      :menu_items => {"Start Game" => :start_game, "HighScores" => HighScoreState, "Quit" => :exit}, 
      :size => 20,
      :factor => 4
    )
    
    $window.reset_game
  end

  def start_game
    $window.next_level
  end
end

class Intro < GameState
  trait :timer
  
  def setup
    on_input([:space, :esc]) { push_game_state(MenuState) }
    GameObject.create(:image => Image["intro.png"], :x => 0, :y => 0, :rotation_center => :top_left)
    @fader = GameObject.create(:image => Image["intro_fader.png"], :x => 50, :y => 0, :rotation_center => :top_left)
    between(5000,15000) { @fader.x -= 1 }.then { push_game_state(MenuState) }
  end
  
  def draw
    fill(Color::BLACK)
    super
  end

end

class GameOverState < GameState
  def setup
    self.input = { :space => MenuState }
    Text.create("GAME OVER!", :x => $window.width/2, :y => 100, :rotation_center => :center)
  end
end

class HighScoreState < GameState
end
