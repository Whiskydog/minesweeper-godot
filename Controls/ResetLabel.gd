extends Label


func _gui_input(event):
	if event.is_action_pressed('mouse_left_button'):
		get_tree().reload_current_scene()
