extends Label

export(String) var scene_path


func _gui_input(event):
	if event.is_action_pressed('mouse_left_button'):
		if scene_path != null:
			get_tree().change_scene(scene_path)
