extends Control

@onready var timer_label = $Label
@onready var lose_level_menu = $"../../LoseLevelMenu"
@onready var warning_rect = $Warning

@export var time_limit = 60.0

var time_remaining = time_limit

func _ready():
	time_remaining = time_limit
	update_timer_display()

func _process(delta):
	time_remaining -= delta
	if time_remaining <= 30:
		warning_rect.visible = true
	if time_remaining <= 0:
		time_remaining = 0
		on_time_over()
	update_timer_display()

func update_timer_display():
	var minutes = int(time_remaining / 60)
	var seconds = int(int(time_remaining) % 60)
	var milliseconds = int((time_remaining - floor(time_remaining)) * 1000)
	timer_label.text = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2) + "." + str(milliseconds).pad_zeros(3)

func on_time_over():
	get_tree().paused = true
	Input.set_custom_mouse_cursor(null)
	lose_level_menu.visible = true
