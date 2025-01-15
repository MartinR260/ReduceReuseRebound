extends Control

@onready var continue_button = $Continue

func _on_new_game_pressed():
	var save_data = {
		"current_level": "res://World.tscn"
	}
	var file = FileAccess.open("user://saves/save_world.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
	else:
		print("Progress NOT saved.")
	get_tree().change_scene_to_file("res://Prologue.tscn")


func _on_quit_game_pressed():
	get_tree().quit()


func _on_continue_pressed():
	var file = FileAccess.open("user://saves/save_world.json", FileAccess.READ)
	if file:
		var save_text = file.get_as_text()
		file.close()
		var json = JSON.new()
		var result = json.parse(save_text)
		var save_data = json.get_data()
		if save_data.has("current_level"):
			get_tree().change_scene_to_file(save_data["current_level"])
			
func _ready():
	var file = FileAccess.open("user://saves/save_world.json", FileAccess.READ)
	if file:
		continue_button.disabled = false
		file.close()
