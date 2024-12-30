extends Control


func _on_next_level_pressed():
	get_tree().paused = false
	visible = false
	if get_tree().current_scene.name == "World":
		get_tree().change_scene_to_file("res://PrologueWorld2.tscn")
	elif get_tree().current_scene.name == "World2":
		get_tree().change_scene_to_file("res://PrologueWorld3.tscn")
	elif get_tree().current_scene.name == "World3":
		get_tree().change_scene_to_file("res://Epilogue.tscn")


func _on_retry_level_pressed():
	get_tree().paused = false
	visible = false
	get_tree().reload_current_scene()


func _on_quit_to_main_menu_pressed():
	get_tree().paused = false
	visible = false
	get_tree().change_scene_to_file("res://MainMenu.tscn")
