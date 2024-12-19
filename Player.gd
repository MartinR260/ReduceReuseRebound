extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@export var SPEED = 130.0
@export var JUMP_VELOCITY = -260.0 #200

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var double_jump = true;
var air_time = 1;
var idle_timer = 0.0
var last_mouse_position = Vector2.ZERO

func _physics_process(delta):
	var mouse_position = get_global_mouse_position()
	var direction = mouse_position - global_position

	var input = Vector2.ZERO
	input.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	if direction.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
		
	if input.x == 0:
		apply_friction()
		
	else:
		#if input.x < 0:
			#sprite.flip_h = true
		#else:
			#sprite.flip_h = false
		if is_on_wall():
			sprite.animation = "Still"
			sprite.play()
		else:
			sprite.animation = "Walk"
			sprite.play()
		apply_acceleration(input.x)
	
	# Add the gravity.
	if not is_on_floor():
		#velocity.y += gravity * air_time * (delta / 2)
		velocity.y += gravity * delta
		air_time += delta
		if velocity.y > 0:
			sprite.animation = "Fall"
			sprite.play()
		elif velocity.y < 0:
			sprite.animation = "Jump"
			sprite.play()
		
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or double_jump):
		double_jump = false;
		air_time /= 1.5
		velocity.y = JUMP_VELOCITY
	else:
		if Input.is_action_just_released("ui_accept"):
			velocity.y = max(-80, velocity.y)
		
		
	if mouse_position != last_mouse_position:
		idle_timer = 0.0
		last_mouse_position = mouse_position
	else:
		idle_timer += delta
		
	if is_on_floor():
		double_jump = false; #Make 'true' for double jump.
		air_time = 1
		if velocity.x == 0:
			if idle_timer > 1.5:
				sprite.animation = "Idle"
				sprite.play()
			else:
				if (direction.angle() > -0.3 and direction.angle() < -0.15) or (direction.angle() > -2.8 and direction.angle() < -2.65):
					sprite.animation = "AimUpStill"
					sprite.play()
				if direction.angle() > -2.65 and direction.angle() < -0.3:
					sprite.animation = "AimAboveStill"
					sprite.play()
				if (direction.angle() < 0.3 and direction.angle() > 0.15) or (direction.angle() < 2.8 and direction.angle() > 2.65):
					sprite.animation = "AimDownStill"
					sprite.play()
				if direction.angle() < 2.65 and direction.angle() > 0.3:
					sprite.animation = "AimUnderStill"
					sprite.play()
				if (direction.angle() > -0.15 and direction.angle() < 0.15) or direction.angle() < -2.8 or direction.angle() > 2.8:
					sprite.animation = "Still"
					sprite.play()
		

	move_and_slide()

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, 14)
	
func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, SPEED * amount, 14)
