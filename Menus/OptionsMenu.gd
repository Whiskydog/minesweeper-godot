extends MarginContainer

export(NodePath) var difficulty_path
onready var difficulty = get_node(difficulty_path)
export(NodePath) var fullscreen_checkbox_path
onready var fullscreen_checkbox = get_node(fullscreen_checkbox_path)


func _ready():
	add_difficulty_options()
	fullscreen_checkbox.pressed = Settings.get_setting('video', 'fullscreen')
	update_fullscreen_checkbox()
	difficulty.connect('item_selected', self, '_on_difficulty_item_selected')
	fullscreen_checkbox.connect('toggled', self, '_on_fullscreen_checkbox_toggled')


func add_difficulty_options():
	difficulty.add_item('Beginner')
	difficulty.add_item('Intermediate')
	difficulty.add_item('Expert')
	difficulty.select(Settings.get_setting('game', 'difficulty').id)


func _on_difficulty_item_selected(id):
	match id:
		0: Settings.set_setting('game', 'difficulty', Global.PRESET_BEGINNER)
		1: Settings.set_setting('game', 'difficulty', Global.PRESET_INTERMEDIATE)
		2: Settings.set_setting('game', 'difficulty', Global.PRESET_EXPERT)
	Settings.save_settings()


func _on_fullscreen_checkbox_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	update_fullscreen_checkbox()
	Settings.set_setting('video', 'fullscreen', button_pressed)
	Settings.save_settings()


func update_fullscreen_checkbox():
	if fullscreen_checkbox.pressed:
		fullscreen_checkbox.text = 'On'
	else:
		fullscreen_checkbox.text = 'Off'
