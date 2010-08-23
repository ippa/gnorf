class Player < GameObject
  traits :collision_detection, :timer, :velocity
  trait :bounding_box, :scale => [0.5,0.9], :debug => false
  attr_reader :throw_energy
  
  def setup
    
    self.input = {  [:holding_left, :holding_a, :gamepad_left] => :holding_left, 
                    [:holding_right, :holding_d, :gamepad_right] => :holding_right,
                    [:down, :s, :gamepad_down] => :down,
                    [:up, :w, :z, :gamepad_button_2, :gamepad_up] => :jump,
                    [:released_down, :released_s] => :stand,
                    [:holding_space, :holding_x, :holding_gamepad_button_1] => :action,
                    [:released_space, :released_x, :released_gamepad_button_1] => :action2
                  }
    
    @animation = Animation.new(:file => "player2.bmp", :size => [35,50], :delay => 50)
    @animation.frame_names = { :walk => 0..1, :grab => 2..2, :crouch => 3..4}
    @image = @animation.first
    
    @jumps = 0
    @speed = 4
    @score = 0
    @throw_energy = 0
    @status = :default
    @action = :default
    @grabbed_game_objects = []
    
    self.zorder = 1
    self.acceleration_y = 0.6
    self.max_velocity = 25
    self.rotation_center = :bottom_center
    cache_bounding_box
  end
    
  def jumping?;   @jumps > 0; end
  def grabbing?;  @status == :grab; end
  
  def hit_by(object)
    $window.energy -= 10
    die if $window.energy <= 0
    Sound["hit.wav"].play(0.3)
    between(1,100) { self.mode = (self.mode == :default) ? :additive : :default }.then { self.mode = :default }
    #5.times { image.set_pixel(object.x10 - rand(5), rand(5), :color => Color::RED) }
  end
    
  def die    
    PuffText.create("You have been slayed by the kings brave men!")
    self.collidable = false
    after(3000) { $window.switch_game_state(EnterNameState) }
  end
  
  def action
    @grabbed_game_objects.empty? ? grab : @throw_energy += 0.15
    @throw_energy = 20 if @throw_energy > 20
  end

  def action2    
    if @action == :default
      throw(throw_energy)
      @throw_energy = 0
    end
    
    @action = :default
  end

  def grab
    @action = :grab
    if @status == :crouch
      @image = @animation[:crouch].last
      x = (self.factor_x > 0) ? bb.right+15 : bb.left-15
      Enemy.each_at(x, bb.bottom - 10) { |enemy| grabbed(enemy) }
      after(100, :name => :ungrab) { @image = @animation[:crouch].first }
    else
      @image = @animation[:grab].last
      x = (self.factor_x > 0) ? bb.right+15 : bb.left-15
      Enemy.each_at(x, bb.center_y) { |enemy| grabbed(enemy) }
      after(100, :name => :ungrab) { @image = @animation[:walk].first }
    end
  end
    
  def throw(energy = 10)
    @grabbed_game_objects.each do |game_object|
      game_object.velocity_x = (self.factor_x > 0) ? energy : -energy
      game_object.velocity_y = -10  unless game_object.acceleration_y == 0
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
    self.velocity_y = -14
  end
  
  def land
    @jumps = 0
  end
  
  #
  # Callback from velocity-trait. It always ends with a call to move(x,y).
  # So we hook into it and add some game / collision detection logic
  #
  def move(x,y)    
    @image = @animation[:walk].next  if @animation && x != 0 && !holding_any?(:space, :down)
    
    self.factor_x = self.factor_x.abs   if x > 0
    self.factor_x = -self.factor_x.abs  if x < 0
    
    self.x += x
    self.x = previous_x   if self.x < 0 || self.x > $window.width
    
    self.y += y
    if self.y > game_state.floor_y
      land
      self.y = game_state.floor_y   
    end
    
    @grabbed_game_objects.each do |game_object|
      game_object.factor_x = self.factor_x
      game_object.x = (self.factor_x > 0) ? self.x+22 : self.x-30
      game_object.y = (@status == :crouch) ? self.y-10 : self.y-22
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
