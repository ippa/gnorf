class Level < GameState
  trait :timer
  attr_reader :player, :game_object_map, :floor_y, :grid, :floor

  def initialize
    super
    self.input = { :esc => :exit }
    
    on_input(:tab) { $window.next_level } unless defined?(Ocra)
    on_input(:e) { edit }                 unless defined?(Ocra)
    
    @floor_y = $window.height + 2 - 32*2
    @player = Player.create(:x => 40, :y => @floor_y)
  end
  
  def setup    
    @grid = [8, 8]
    @file = File.join(ROOT, "#{self.class.to_s.downcase}.yml")

    game_objects.select { |game_object| !game_object.is_a? Player }.each { |game_object| game_object.destroy }
    load_game_objects(:file => @file)
    @game_object_map = GameObjectMap.new(:game_objects => Block.all + Floor.all, :grid => @grid)
    @energy_font = Font.new($window, Gosu::default_font_name, 20)    
    @floor = Floor.all.first
    
    $window.last_level = self.class.to_s
  end
  
  def edit
    push_game_state GameStates::Edit.new(:grid => @grid, :except => [Player, PuffText, Smokepuff, Weapon], :file => @file, :debug => false)
  end
  
  def draw
    fill_gradient(:from => Color::BLUE, :to => Color::CYAN)
    super
  end
  
  def update
    super
    
    @player.each_collision(Horse.attacking) do |player, horse|
      player.hit_by(horse)
      horse.destroy
    end
    
    #@player.each_collision(Horse) do |player, horse|
    #  player.hit_by(horse)
    #  horse.destroy
    #end

    Weapon.each_collision(@player) do |weapon, player|
      player.hit_by(weapon)
      weapon.explode
    end
    
    King.each_collision(Enemy.thrown) do |king, enemy|
      Sound["win.wav"].play(0.2)
      king.hit_by(enemy)
      king.destroy
      enemy.destroy
      PuffText.create("You killed the KING!", :x => $window.width/2, :y => $window.height/2)      
      if self.is_a? Level10
        switch_game_state(EnterMenuState)
      else
        after(3000) { $window.next_level }
      end
    end
      
    Block.each_collision(Enemy.thrown) do |block, enemy|
      enemy.destroy
      block.hit_by(enemy)
    end
    
    @energy_font.draw("Energy: #{$window.energy}", 10, 10, 10)
    @energy_font.draw("Score: #{$window.score}", 300, 10, 10)
    @energy_font.draw("Throw Speed: #{@player.throw_energy.to_i}", 600, 10, 10)
    $window.caption = "Gnorf (is breaking an entrence). LD#18 entry by http://ippa.se/gaming - [#{self.class.to_s}/#{@player.x}/#{@player.y}/#{$window.fps}] "
    
  end
  
  def fire_gun
    StonewallGun.all.first.attack rescue nil
  end

  def fire_mortar
    StonewallMortar.all.first.attack rescue nil
  end
  
  def spawn_knight
    Knight.create(:x => $window.width - 50, :y => 550)  if  Knight.all.size < 10
  end
  
  def spawn_horse
    Horse.create(:x => $window.width - 100, :y => 550)  if  Horse.all.size < 4
  end
  
  def spawn_balloon
    Balloon.create(:x => $window.width - 150, :y => 300) if  Balloon.all.size < 4
  end

end

class Level1 < Level
  def setup
    super
    #Horse.create(:x => $window.width - 300, :y => 550)  if  Knight.all.size < 4
    #spawn_horse
    spawn_knight
    every(5000, :name => :knight) { spawn_knight }
    every(12000, :name => :horse) { spawn_horse }
  end
end

class Level2 < Level
  def setup
    super
    Balloon.create(:x => $window.width - rand(500), :y => 200)
    spawn_knight
    every(7000, :name => :knight) { spawn_knight }
    every(10000, :name => :horse)  { spawn_horse }  
  end
end

class Level3 < Level
  def setup
    super
    spawn_knight
    Balloon.create(:x => $window.width - rand(500), :y => 200)
    every(4000, :name => :gun) { fire_gun }  
    every(5000, :name => :knight) { spawn_knight }
    every(9000, :name => :horse) { spawn_horse }
    every(30000, :name => :balloon) { spawn_balloon }
  end
end
class Level4 < Level
  def setup
    super
    spawn_horse
    Balloon.create(:x => $window.width - rand(500), :y => 200)
    Balloon.create(:x => $window.width - rand(500), :y => 200)
    every(4000, :name => :gun) { fire_gun }  
    every(5000, :name => :knight) { spawn_knight }
    every(8000, :name => :horse) { spawn_horse } 
    every(30000, :name => :balloon) { spawn_balloon }
  end
end
class Level5 < Level
  def setup
    super
    spawn_knight
    Balloon.create(:x => $window.width - rand(500), :y => 200)
    Balloon.create(:x => $window.width - rand(500), :y => 200)
    every(5000, :name => :gun) { fire_gun }  
    every(10000, :name => :knight) { spawn_knight }
    every(9000, :name => :horse) { spawn_horse }
    every(30000, :name => :balloon) { spawn_balloon }
  end
end

class Level6 < Level
  def setup
    super
    spawn_knight
    Balloon.create(:x => $window.width - rand(500), :y => 200)
    Balloon.create(:x => $window.width - rand(500), :y => 200)
    every(5000, :name => :gun) { fire_gun }  
    every(10000, :name => :knight) { spawn_knight }
    every(9000, :name => :horse) { spawn_horse }     
    every(30000, :name => :balloon) { spawn_balloon }
    every(6000, :name => :mortar) { fire_mortar } 
  end
end

class Level7 < Level
  def setup
    super
    spawn_knight
    Balloon.create(:x => $window.width - rand(500), :y => 200)
    Balloon.create(:x => $window.width - rand(500), :y => 200)
    every(5000, :name => :gun) { fire_gun }  
    every(10000, :name => :knight) { spawn_knight }
    every(9000, :name => :horse) { spawn_horse }     
    every(25000, :name => :balloon) { spawn_balloon }    
    every(6000, :name => :mortar) { fire_mortar } 
  end
  
end
class Level8 < Level
  def setup
    super
    spawn_knight
    Balloon.create(:x => $window.width - rand(500), :y => 200)
    Balloon.create(:x => $window.width - rand(500), :y => 200)
    every(5000, :name => :gun) { fire_gun }  
    every(10000, :name => :knight) { spawn_knight }
    every(9000, :name => :horse) { spawn_horse }     
    every(25000, :name => :balloon) { spawn_balloon }
    every(6000, :name => :mortar) { fire_mortar } 
  end
  
end
class Level9 < Level
  def setup
    super
    spawn_knight
    Balloon.create(:x => $window.width - rand(500), :y => 200)
    Balloon.create(:x => $window.width - rand(500), :y => 200)
    every(5000, :name => :gun) { fire_gun }
    every(6000, :name => :mortar) { fire_mortar } 
    every(10000, :name => :knight) { spawn_knight }
    every(9000, :name => :horse) { spawn_horse }
    every(25000, :name => :balloon) { spawn_balloon }    
  end
  
end
class Level10 < Level
  def setup
    super
    spawn_horse
    spawn_balloon
    every(20000, :name => :balloon) { spawn_balloon }
    every(5000, :name => :gun) { fire_gun }
    every(6000, :name => :mortar) { fire_mortar } 
    every(6000, :name => :knight) { spawn_knight }
    every(7000, :name => :horse) { spawn_horse }     
  end  
end
