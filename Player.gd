extends CharacterBody2D
var rocket_scene = preload("res://Rocket.tscn")
var breakable_scene = preload("res://Breakable.tscn")

@onready var sprite = $AnimatedSprite2D
@onready var walk_sound = $Node/Walk
@onready var jump_sound = $Node/Jump
@onready var shoot_sound = $Node/Shoot
@onready var place_sound = $Node/Place
@onready var fall_sound = $Node/Fall

@onready var placing_pointer = $"../Placer"
@onready var camera = $"../Camera"
@onready var ui = $"../UI"
@onready var pause_menu = $"../PauseMenu"
@onready var finished_level_menu = $"../FinishedLevelMenu"
@onready var lose_level_menu = $"../LoseLevelMenu"

@onready var crosshair = preload("res://kenney_assets/cursor_crosshair.png")
@onready var dimmed_crosshair = preload("res://kenney_assets/dimmed_crosshair.png")
@onready var place_allowed = preload("res://kenney_assets/place_allowed.png")
@onready var place_forbidden = preload("res://kenney_assets/place_forbidden.png")
@onready var too_far_placer = preload("res://kenney_assets/dimmed_cursor_block.png")
@onready var valid_placer = preload("res://kenney_assets/cursor_block.png")

@export var SPEED = 130.0
@export var JUMP_VELOCITY = -260.0
@export var cooldown_time = 0.85 #1.15

var last_shot_time = -cooldown_time
var collected_blocks = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var double_jump = true;
var air_time = 1;
var idle_timer = 0.0
var last_mouse_position = Vector2.ZERO
var build_mode = false
var gun_mode = true
var mouse_offset = Vector2.ZERO
var walk_sound_cooldown = 0.2
var last_walk_sound_time = 0
var blocks_counter

func _physics_process(delta):
	
	camera.global_position.x = 576 * (int(global_position.x) / 576) #the number is equal to the screen width
	ui.global_position.x = 576 * (int(global_position.x) / 576)
	pause_menu.global_position.x = 576 * (int(global_position.x) / 576)
	finished_level_menu.global_position.x = 576 * (int(global_position.x) / 576)
	if get_tree().current_scene.name != "World":
		lose_level_menu.global_position.x = 576 * (int(global_position.x) / 576)
	
	if global_position.y >= 330:
		fall_sound.play()
		global_position.x = 576 * (int(global_position.x) / 576) + 50
		global_position.y = 100
		velocity.y = 0
		
	if Input.is_action_just_pressed("build_mode"):
		Input.set_custom_mouse_cursor(place_allowed, Input.CURSOR_ARROW, Vector2(0, 0))
		build_mode = true
		gun_mode = false
	elif Input.is_action_just_pressed("gun_mode"):
		placing_pointer.global_position = Vector2(-9,-9)
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
			if is_on_floor() and ((Time.get_ticks_msec() / 1000.0) - last_walk_sound_time > walk_sound_cooldown):
				last_walk_sound_time = Time.get_ticks_msec() / 1000.0
				walk_sound.play()
			sprite.animation = "Walk"
			sprite.play()
			
		if collected_blocks <= 3:
			if input.x > 0:
				input.x -= collected_blocks * 0.115
			elif input.x < 0:
				input.x += collected_blocks * 0.115
		else:
			if input.x > 0:
				input.x -= 0.330
			elif input.x < 0:
				input.x += 0.330
				
		apply_acceleration(input.x)
		
	if build_mode:
		if !check_cursor_overlap(mouse_position):
			if collected_blocks > 0 and is_placer_close_enough(mouse_position):
				placing_pointer.texture = valid_placer
				Input.set_custom_mouse_cursor(place_allowed, Input.CURSOR_ARROW, Vector2(0, 0))
			else:
				placing_pointer.texture = too_far_placer
				Input.set_custom_mouse_cursor(place_forbidden, Input.CURSOR_ARROW, Vector2(0, 0))
			mouse_offset = Vector2(-9, -9) + mouse_position
			placing_pointer.global_position = (Vector2(9, 9) + mouse_offset.snapped(Vector2(18, 18)))
		else:
			Input.set_custom_mouse_cursor(place_forbidden, Input.CURSOR_ARROW, Vector2(0, 0))
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
		jump_sound.play()
		double_jump = false;
		air_time /= 1.5
		velocity.y = JUMP_VELOCITY
		if collected_blocks <= 3:
			velocity.y += collected_blocks * 20
		else:
			velocity.y += 60
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
				change_aim_angle(direction)
		
	if (Time.get_ticks_msec() / 1000.0) - last_shot_time < cooldown_time:
		Input.set_custom_mouse_cursor(dimmed_crosshair, Input.CURSOR_ARROW, Vector2(16, 16))
		
		
	if Input.is_action_just_pressed("left_click") and gun_mode and ((Time.get_ticks_msec() / 1000.0) - last_shot_time >= cooldown_time):
		shoot_sound.play()
		last_shot_time = (Time.get_ticks_msec() / 1000.0) 
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
		
		
	blocks_counter = ui.get_child(4)
	blocks_counter.text = "Blocks: " + str(collected_blocks)
# uncomment for color indication of collected blocks
	#if collected_blocks == 0:
		#blocks_counter.modulate = Color(1, 1, 1)
	#if collected_blocks == 1:
		#blocks_counter.modulate = Color(1, 0.9, 0.4)
	#if collected_blocks == 2:
		#blocks_counter.modulate = Color(1, 0.6, 0.2)
	#if collected_blocks >= 3:
		#blocks_counter.modulate = Color(1, 0.3, 0.2)
		
		
	if Input.is_action_just_pressed("left_click") and !check_cursor_overlap(mouse_position) and build_mode and collected_blocks > 0 and is_placer_close_enough(mouse_position):
		place_sound.play()
		collected_blocks -= 1
		var breakable = breakable_scene.instantiate()
		breakable.global_position = placing_pointer.global_position
		get_parent().add_child(breakable)
		
	move_and_slide()

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, 14)
	
func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, SPEED * amount, 14)
	
func change_aim_angle(direction):
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
	
func check_cursor_overlap(cursor_position):
	var space_state = get_world_2d().direct_space_state
	var query_parameters = PhysicsPointQueryParameters2D.new()
	query_parameters.set_position(cursor_position)
	query_parameters.collision_mask = 0b111
	var collision = space_state.intersect_point(query_parameters, 1)
	
	if collision:
		# print(collision[0])
		if collision[0].collider.name == "Player" or collision[0].collider.name == "TileMap" or collision[0].collider.name == "TileMap2" or collision[0].collider.name == "TileMap3" or collision[0].collider.name.begins_with("Breakable") or collision[0].collider.name.begins_with("Breakable") or collision[0].collider.name.begins_with("@RigidBody2D"):
			return true
	else:
		return false

func is_placer_close_enough(mouse_position):
	if (!(global_position.y - mouse_position.y <= 22 and global_position.y - mouse_position.y >= -13) or !(global_position.x - mouse_position.x >= -10 and global_position.x - mouse_position.x <= 10)) and (global_position.x - mouse_position.x >= -48 and global_position.x - mouse_position.x <= 48 and global_position.y - mouse_position.y >= -50 and global_position.y - mouse_position.y <= 40):
		return true
	else:
		return false

