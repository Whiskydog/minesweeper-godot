extends Control

onready var board = $CenterContainer/Board
onready var header = $HBoxContainer
onready var timer = $HBoxContainer/TimeCounter/Timer
onready var counter = $HBoxContainer/MineCounter/Counter


func _ready():
	board.connect('toggled_mine', self, '_on_grid_toggled_mine')
	board.connect('game_won', self, '_on_grid_game_won')
	board.connect('first_move_done', self, '_on_grid_first_move_done')
	board.connect('cell_flagged', self, '_on_board_cell_flagged')
	header.margin_bottom -= board.rect_size.y / 2 + header.rect_size.y / 1.5
	header.margin_top -= board.rect_size.y / 2 + header.rect_size.y / 1.5
	update_counter_text(board.mine_count)


func _on_grid_game_won():
	timer.stop()


func _on_grid_first_move_done():
	board.disconnect('first_move_done', self, '_on_grid_first_move_done')
	timer.start()


func _on_grid_toggled_mine():
	timer.stop()


func _on_board_cell_flagged(flagged):
	if flagged:
		update_counter_text(int(counter.text) - 1)
	else:
		update_counter_text(int(counter.text) + 1)


func update_counter_text(n):
	counter.text = '%03d' % n
