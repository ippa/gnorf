class Enemy < GameObject
  traits :collision_detection, :timer, :velocity
  trait :bounding_box, :debug => false
  
  attr_reader :thrown
    
  def setup
    @image = Image["#{self.filename}.bmp"] rescue nil
    self.rotation_center = :center_bottom
    self.acceleration_y = 0.4
    self.zorder = 2
    self.max_velocity = 20
    
    @grabbed_by = nil
    @thrown = false
    @angle_velocity = 0
    @attack_image = nil
    @status = :default
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
    if self.y > game_state.floor_y
      self.y = game_state.floor_y
      if self.velocity_x > 1
        self.velocity_x = self.velocity_x / 2
      end
    end
    
    self.angle += @angle_velocity
  end  
end

class Knight < Enemy
  trait :animation
  
  def setup
    super
    @attack_image = self.animation.frames.pop
    self.velocity_x = -1
    every(2000) { attack }
  end
end

class Horse < Enemy 
  trait :animation, :delay => 30
  def setup
    super
    self.velocity_x = -3
  end
end

class Balloon < Enemy 
  trait :animation, :delay => 500
  def setup
    super
    every(2000 + rand(1000) ) { change_direction }
    every(10000) { Bomb.create(:x => self.x, :y => self.y) }
    self.acceleration_y = 0
  end
  
  def change_direction
    self.velocity_x = (game_state.player.x < self.x) ? -rand*2 : rand*2
    self.velocity_y = self.y < 50 ? rand : (0.5 - rand)
  end
  
end

class Bomb < Enemy
  trait :animation
  
  def setup
    super
    self.acceleration_y = 0.2
    after(4000) { explode }
  end
  
  def explode
    Smokepuff.create(:x => x, :y => y, :color => Color::RED.dup, :scale => 3)
    Smokepuff.create(:x => x, :y => y, :color => Color::YELLOW.dup, :scale => 3)
    destroy
    #Sound["bomb.wav"].play(0.3)
  end
end