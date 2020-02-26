extends Control

onready var grid = $CenterContainer/Grid
onready var header = $HBoxContainer
onready var timer = $HBoxContainer/TimeCounter/Timer


func _ready():
	grid.connect('toggled_mine', self, '_on_grid_toggled_mine')
	grid.connect('game_won', self, '_on_grid_game_won')
	grid.connect('first_move_done', self, '_on_grid_first_move_done')
	header.margin_bottom -= grid.rect_size.y / 2 + header.rect_size.y / 1.5
	header.margin_top -= grid.rect_size.y / 2 + header.rect_size.y / 1.5


func _on_grid_game_won():
	timer.stop()


func _on_grid_first_move_done():
	grid.disconnect('first_move_done', self, '_on_grid_first_move_done')
	timer.start()


func _on_grid_toggled_mine():
	timer.stop()
