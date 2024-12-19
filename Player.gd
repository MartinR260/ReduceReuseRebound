extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@export var SPEED = 130.0
@export var JUMP_VELOCITY = -270.0 #200

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var double_jump = true;
var air_time = 1;

func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if input.x == 0:
		apply_friction()
	else:
		if input.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
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
			velocity.y = max(-80, velocity.y) #-80
		
	if is_on_floor():
		double_jump = false; #Make 'true' for double jump.
		air_time = 1
		if velocity.x == 0:
			sprite.animation = "Idle"
			sprite.play()

	move_and_slide()

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, 14)
	
func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, SPEED * amount, 14)
