class Level < GameState
  trait :timer
  attr_reader :player, :game_object_map, :floor_y, :grid

  def initialize
    super
    
    self.input = { :esc => :exit, :e => :edit }
    
    @floor_y = $window.height + 2 - 32*2
    @grid = [8, 8]
    @file = File.join(ROOT, "#{self.class.to_s.downcase}.yml")
    load_game_objects(:file => @file)
    
    @player = Player.create(:x => 40, :y => @floor_y)
  end
  
  def setup
    @game_object_map = GameObjectMap.new(:game_objects => Block.all + Grass.all, :grid => @grid)
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
    
    @player.each_collision(Enemy) do |player, enemy|
      if player.grabbing?
        player.grabbed(enemy)
      else
        player.hit_by(enemy)
        enemy.hit_by(player)
      end
    end
    
    Enemy.each_collision(Block) do |enemy, block|
      if enemy.thrown
        enemy.destroy
        block.hit_by(enemy)
      end
    end
        
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
    Horse.create(:x => $window.width - 100, :y => 550)
    every(1000) { Knight.create(:x => $window.width - 50, :y => 550) }
  end
  
end