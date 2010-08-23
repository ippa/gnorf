class Enemy < GameObject
  traits :collision_detection, :timer, :velocity
  trait :bounding_box, :debug => false, :scale => [1, 0.7]
  
  attr_accessor :energy, :score
  attr_reader :thrown
  
  def Enemy.thrown
    all.select { |object| object.thrown }
  end
    
  def setup
    @image = Image["#{self.filename}.bmp"] rescue nil    
    
    self.rotation_center = :center_bottom
    self.acceleration_y = 0.4
    self.zorder = 2
    self.max_velocity = 20
    self.factor = 2
    
    @grabbed_by = nil
    @thrown = false
    @angle_velocity = 0
    @attack_image = nil
    @status = :default
    @score = 0
    @energy = 10
  end
    
  def update
    self.image = animation.next   if animation && !@grabbed_by && @status == :default
    self.velocity_x = -self.velocity_x  if self.outside_window?
  end
  
  def grabbed?
    @grabbed_by
  end  
  
  def thrown_by(game_object)
    @grabbed_by = nil
    @thrown = true
    @angle_velocity = rand(10)
    self.rotation_center = :center_center
  end
  
  def grabbed_by(game_object)
    self.image = animation.first
    @grabbed_by = game_object
  end
  
  def hit_by(object)
  end
  
  def attack
    return if grabbed? || thrown
    
    @status = :attack
    after(600) { @status = :default }
    @image = @attack_image  if @attack_image
    game_state.player.hit_by(self) if self.collides?(game_state.player)
  end
  
  def move(x, y)
    return if grabbed? || @status == :attack
    
    self.factor_x = -self.factor_x.abs    if x > 0
    self.factor_x = self.factor_x.abs     if x < 0
    
    self.x += x
    
    self.y += y
    bounce  if self.y > game_state.floor_y    
    self.angle += @angle_velocity
  end
  
  def bounce
    self.y = game_state.floor_y
    if self.velocity_x > 1
      self.velocity_x = self.velocity_x / 2
      self.velocity_y = -self.velocity_y / 2
      @angle_velocity = 0
      5.times { game_state.floor.image.set_pixel(self.x/2 + rand(10), rand(5), :color => Color::RED) }
      Sound["bounce.wav"].play(0.3)
    else
      self.angle = 0
      @thrown = false
      self.rotation_center = :center_bottom
    end
  end
end

class King < Enemy
  trait :animation, :delay => 1500, :bounce => true
  
  def setup
    super
    @image = self.animation.first
    @energy = 30
  end
  
  def grabbed_by(game_object)
    false
  end
  
  def move(x, y)
    self.factor_x = -self.factor_x.abs    if x > 0
    self.factor_x = self.factor_x.abs     if x < 0
       
    self.y += y
    self.y = previous_y if  game_state.game_object_map.from_game_object(self)
  end
  
  def say(msg = "Kill that foul beast!")
  end
end


class Knight < Enemy
  trait :animation
  
  def setup
    super
    @attack_image = self.animation.frames.pop
    self.velocity_x = -1
    @energy = 20
    every(2000) { attack }
  end
end

class Horse < Enemy 
  trait :animation, :delay => 30
  def setup
    super
    self.velocity_x = -3
    @energy = 50
  end
end

class Balloon < Enemy 
  trait :animation, :delay => 1500
  def setup
    super
    every(2000 + rand(1000) ) { change_direction }
    every(10000) { Bomb.create(:x => self.x, :y => self.y) }
    self.acceleration_y = 0
    @energy = 75
  end
  
  def change_direction
    self.velocity_x = (game_state.player.x < self.x) ? -rand*2 : rand*2
    self.velocity_y = self.y < 50 ? rand : (0.5 - rand)
  end
  
  def update
    super
    self.factor_x = 2
  end  
end
