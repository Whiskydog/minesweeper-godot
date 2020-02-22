extends Control

onready var grid = $CenterContainer/Grid
onready var debug_label = $ButtonGridPosition

var first_move_done = false
var game_over = false


func _ready():
	Global.game = self
	for button in grid.get_children():
		button.connect('mouse_has_entered', self, '_on_button_mouse_has_entered')
		button.connect('mouse_exited', self, '_on_button_mouse_exited')
	
	var reset_label = $Reset
	reset_label.margin_bottom -= grid.rect_size.y / 2 + reset_label.rect_size.y / 2
	reset_label.margin_top -= grid.rect_size.y / 2 + reset_label.rect_size.y / 2

	grid.connect('toggled_mine', self, '_on_grid_toggled_mine')


func _on_button_mouse_has_entered(button):
	debug_label.text = button.grid_pos_to_string()


func _on_button_mouse_exited():
	debug_label.text = ''


func _on_grid_toggled_mine():
	game_over = true
	grid.reveal_mines()
