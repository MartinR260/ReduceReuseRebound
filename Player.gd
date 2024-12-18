extends CharacterBody2D

@export var SPEED = 130.0
@export var JUMP_VELOCITY = -200.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var double_jump = true;
var air_time = 1;

func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if input.x == 0:
		apply_friction()
	else:
		apply_acceleration(input.x)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * air_time * (delta / 2)
		air_time += delta
		
	# Handle jump.
	if Input.is_action_pressed("ui_accept") and (is_on_floor() or double_jump):
		double_jump = false;
		air_time /= 1.5
		velocity.y = JUMP_VELOCITY
	else:
		if Input.is_action_just_released("ui_accept"):
			velocity.y = max(-80, velocity.y)
		
	if is_on_floor():
		double_jump = false; #Make 'true' for double jump.
		air_time = 1

	move_and_slide()

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, 14)
	
func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, SPEED * amount, 14)
