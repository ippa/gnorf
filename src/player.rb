
class Player < GameObject
  traits :collision_detection, :timer, :velocity
  trait :bounding_box, :scale => 0.8, :debug => false

  def setup
    
    self.input = {  [:holding_left, :holding_a] => :holding_left, 
                    [:holding_right, :holding_d] => :holding_right,
                    [:down, :s] => :down,
                    [:up, :w] => :jump,
                    [:released_down, :released_s] => :stand,
                    [:space] => :grab,
                    [:holding_lctrl] => :aim,
                    [:released_lctrl] => :throw,
                  }
    
    @animation = Animation.new(:file => "player.bmp", :size => [35,50], :delay => 50)
    @animation.frame_names = { :walk => 0..1, :grab => 2..2, :crouch => 3..4}
    @image = @animation.first
    
    @jumps = 0
    @speed = 4
    @score = 0
    @status = :default
    @grabbed_game_objects = []
    
    self.zorder = 1
    self.acceleration_y = 0.5
    self.max_velocity = 25
    self.rotation_center = :bottom_center
  end
    
  def jumping?;   @jumps > 0; end
  def grabbing?;  @status == :grab; end
  
  def hit_by(object)
  end
  
  def die
    self.collidable = false
    @color = Color::RED
    @died_at = [self.x, self.y]
    between(1,600) { self.scale += 0.4; self.alpha -= 5; }.then { resurrect }
    Sound["hurt.ogg"].play(0.3)
    self.velocity_y = -13
  end
  
  def grab
    if @status == :crouch
      @image = @animation[:crouch].last
      Enemy.each_at(bb.right + 5, bb.bottom - 10) { |enemy| grabbed(enemy) }
      Enemy.each_at(bb.right + 5, bb.bottom - 10) { |enemy| grabbed(enemy) }
      after(100, :name => :ungrab) { @image = @animation[:crouch].first }
    else
      @image = @animation[:grab].last
      Enemy.each_at(bb.right + 5, bb.center_y) { |enemy| grabbed(enemy) }
      after(100, :name => :ungrab) { @image = @animation[:walk].first }
    end
  end
  
  def aim
    @status = :aiming
  end
  
  def throw
    #Sound["fly.ogg"].play(0.2)  unless @grabbed_game_objects.empty?
    
    @grabbed_game_objects.each do |game_object|
      game_object.velocity_x = (self.factor_x > 0) ? 10 : -10
      game_object.velocity_y = -7
      game_object.thrown_by(self)
    end
    @grabbed_game_objects.clear
  end
    
  def grabbed(game_object)
    return if game_object.grabbed?      # already grabbed? do nothing.
    
    game_object.zorder = self.zorder - 1
    game_object.grabbed_by(self)
    @grabbed_game_objects << game_object
  end
    
  def stand
    @image = @animation[:walk].first
    @status = :default
  end
    
  def down
    if jumping?
      self.velocity_y = 20
      @status = :default
    else
      @status = :crouch
      @image = @animation[:crouch].first
    end
  end
  
  def holding_left
    return if @status == :crouch
    move(-@speed, 0)
  end

  def holding_right
    return if @status == :crouch
    move(@speed, 0)
  end

  def jump
    return if jumping?
    @jumps += 1
    self.velocity_y = -15
    Sound["jump2.ogg"].play(0.2)
  end
  
  def land
    @jumps = 0
    #Sound["land.wav"].play(0.3) if self.velocity_y > 10
  end
  
  #
  # Callback from velocity-trait. It always ends with a call to move(x,y).
  # So we hook into it and add some game / collision detection logic
  #
  def move(x,y)
    @image = @animation[:walk].next  if @animation  if x != 0
    
    self.factor_x = self.factor_x.abs   if x > 0
    self.factor_x = -self.factor_x.abs  if x < 0
    
    self.x += x
    self.x = previous_x   if self.x < 0 || self.x > $window.width
    #if game_state.game_object_map.from_game_object(self)
    #  self.x = previous_x
    #  self.velocity_x = 0
    #end
    
    self.y += y
    if self.y > game_state.floor_y
      land
      self.y = game_state.floor_y   
    end
    
    @grabbed_game_objects.each do |game_object|
      game_object.factor_x = self.factor_x
      if self.factor_x > 0
        game_object.x = self.x + 22
      else
        game_object.x = self.x - 30
      end
      game_object.y = self.y - 22
    end
  end
    
  def update
    #if block = game_state.game_object_map.from_game_object(self)
    #  
    #  if self.velocity_y < 0
    #    self.y = block.bb.bottom + self.height
    #  else
    #    self.y = block.bb.top-1
    #    land
    #  end
    #  self.velocity_y = 0
    #  self.velocity_x = 0
    #end
    
  end
end
