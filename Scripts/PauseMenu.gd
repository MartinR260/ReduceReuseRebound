extends Control

func _on_continue_pressed():
	get_tree().paused = false
	visible = false


func _on_retry_pressed():
	get_tree().paused = false
	visible = false
	get_tree().reload_current_scene()


func _on_quit_pressed():
	get_tree().paused = false
	visible = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

