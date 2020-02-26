extends Node

const PRESET_BEGINNER = {
	'id': 0,
	'rows': 9,
	'columns': 9,
	'mine_count': 10
}
const PRESET_INTERMEDIATE = {
	'id': 1,
	'rows': 16,
	'columns': 16,
	'mine_count': 40
}
const PRESET_EXPERT = {
	'id': 2,
	'rows': 16,
	'columns': 30,
	'mine_count': 99
}


func _ready():
	randomize()


func _input(event):
	if event.is_action_pressed('quit'):
		get_tree().quit()