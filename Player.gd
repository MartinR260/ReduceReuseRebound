extends CharacterBody2D
var rocket_scene = preload("res://Rocket.tscn")
var breakable_scene = preload("res://Breakable.tscn")

@onready var sprite = $AnimatedSprite2D
@onready var placing_pointer : Sprite2D = $Sprite2D
@onready var crosshair = preload("res://kenney_assets/cursor_crosshair.png")
@export var SPEED = 130.0
@export var JUMP_VELOCITY = -260.0 #200

var collected_blocks = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var double_jump = true;
var air_time = 1;
var idle_timer = 0.0
var last_mouse_position = Vector2.ZERO
var build_mode = false
var gun_mode = true
var mouse_offset = Vector2.ZERO

func _physics_process(delta):
	if Input.is_action_just_pressed("build_mode"):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		build_mode = true
		gun_mode = false
	elif Input.is_action_just_pressed("gun_mode"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		placing_pointer.global_position = Vector2(-9, -9)
		Input.set_custom_mouse_cursor(crosshair, Input.CURSOR_ARROW, Vector2(16, 16))
		gun_mode = true
		build_mode = false
	
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

		if is_on_wall():
			sprite.animation = "Still"
			sprite.play()
		else:
			sprite.animation = "Walk"
			sprite.play()
		apply_acceleration(input.x)
		
	if build_mode:
		if !check_cursor_overlap(mouse_position):
			mouse_offset = Vector2(-9, -9) + mouse_position
			placing_pointer.global_position = (Vector2(9, 9) + mouse_offset.snapped(Vector2(18, 18)))
	if gun_mode:
		Input.set_custom_mouse_cursor(crosshair, Input.CURSOR_ARROW, Vector2(16, 16))
	
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
	if Input.is_action_just_pressed("jump") and (is_on_floor() or double_jump):
		double_jump = false;
		air_time /= 1.5
		velocity.y = JUMP_VELOCITY
	else:
		if Input.is_action_just_released("jump"):
			velocity.y = max(-80, velocity.y)
		
	if mouse_position != last_mouse_position:
		idle_timer = 0.0
		last_mouse_position = mouse_position
	else:
		idle_timer += delta
		
		
	if is_on_floor():
		double_jump = false; #Make 'true' for double jump
		air_time = 1
		if velocity.x == 0:
			if idle_timer > 1.5:
				sprite.animation = "Idle"
				sprite.play()
			else:
				if (direction.angle() > -0.3 and direction.angle() < -0.15) or (direction.angle() > -3 and direction.angle() < -2.65):
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
		
		
	if Input.is_action_just_pressed("left_click") and gun_mode:
		var rocket = rocket_scene.instantiate()
		rocket.direction = direction.angle()
		rocket.starting_rotation = direction.angle()
		if sprite.flip_h:
			if direction.angle() > -2 and direction.angle() < -1:
				rocket.starting_position = Vector2(global_position.x - 9, global_position.y - 20)
			elif direction.angle() < 2 and direction.angle() > 1:
				rocket.starting_position = Vector2(global_position.x - 9, global_position.y + 20)
			else:
				rocket.starting_position = Vector2(global_position.x - 18, global_position.y + 2)
		else:
			if direction.angle() > -2 and direction.angle() < -1:
				rocket.starting_position = Vector2(global_position.x + 9, global_position.y - 20)
			elif direction.angle() < 2 and direction.angle() > 1:
				rocket.starting_position = Vector2(global_position.x + 9, global_position.y + 20)
			else:
				rocket.starting_position = Vector2(global_position.x + 18, global_position.y + 2)
				
		rocket.connect("broken_block", func(): collected_blocks+=1)
		get_parent().add_child(rocket)
		
		
	if Input.is_action_just_pressed("right_click") and build_mode and collected_blocks > 0 and (global_position.distance_to(mouse_position) <= 54 or global_position.distance_to(mouse_position) >= 36):
		collected_blocks -= 1
		var breakable = breakable_scene.instantiate()
		breakable.global_position = placing_pointer.global_position
		get_parent().add_child(breakable)
		
	move_and_slide()

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, 14)
	
func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, SPEED * amount, 14)
	
func check_cursor_overlap(cursor_position):
	var space_state = get_world_2d().direct_space_state
	var query_parameters = PhysicsPointQueryParameters2D.new()
	query_parameters.set_position(cursor_position)
	query_parameters.collision_mask = 0b111
	var collision = space_state.intersect_point(query_parameters, 1)
	
	if collision:
		# print(collision[0])
		if collision[0].collider.name == "Player" or collision[0].collider.name == "TileMap" or collision[0].collider.name.begins_with("Breakable") or collision[0].collider.name.begins_with("Breakable") or collision[0].collider.name.begins_with("@RigidBody2D"):
			return true
	else:
		return false

