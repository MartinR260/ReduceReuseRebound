extends Control

@onready var gun_mode_icon = $GunModeIcon
@onready var build_mode_icon = $BuildModeIcon
@onready var pause_button = $PauseButton
@onready var pause_menu = $"../PauseMenu"

@onready var gun_selected = preload("res://kenney_assets/selected_gun_mode_ui.png")
@onready var gun_unselected = preload("res://kenney_assets/gun_mode_ui.png")

@onready var build_selected = preload("res://kenney_assets/selected_build_mode_ui.png")
@onready var build_unselected = preload("res://kenney_assets/build_mode_ui.png")

@onready var pause_normal = preload("res://kenney_assets/pause_button.png")
@onready var pause_hover = preload("res://kenney_assets/pause_button_hover.png")
@onready var pause_pressed = preload("res://kenney_assets/pause_button_pressed.png")

func _process(delta):
	if Input.is_action_just_pressed("gun_mode"):
		build_mode_icon.texture = build_unselected
		gun_mode_icon.texture = gun_selected
	elif Input.is_action_just_pressed("build_mode"):
		gun_mode_icon.texture = gun_unselected
		build_mode_icon.texture = build_selected

func _on_pause_button_pressed():
	get_tree().paused = true
	Input.set_custom_mouse_cursor(null)
	pause_menu.visible = true
