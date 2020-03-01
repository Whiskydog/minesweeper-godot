extends Button
class_name Cell

enum State { NUMBER = 1, MINE = 2 }

onready var board = get_parent()

var board_pos = { row = 0, column = 0 }
var mines_adjacent = 0
var flagged_adjacent = 0
var unavailable = false setget set_unavailable
var flagged = false setget flag, is_flagged
var state = 0


func _init(size, row, column):
	._init()
	board_pos.row = row
	board_pos.column = column
	toggle_mode = true
	rect_min_size = Vector2.ONE * size
	focus_mode = FOCUS_NONE
	mouse_filter = MOUSE_FILTER_IGNORE
	align = Button.ALIGN_CENTER


func board_pos_to_string():
	return str(board_pos.row) + ', ' + str(board_pos.column)


func has_mine_around():
	for cell in board.get_adjacent(self):
		if cell.is_mine():
			return true
	return false


func is_mine():
	return state == State.MINE


func set_unavailable(value = true):
	if unavailable == value:
		return
	unavailable = value
	if unavailable:
		if flagged:
			flag(false)
		if not pressed:
			pressed = true
		
		if is_mine():
			board.emit_signal('toggled_mine')
		else:
			if mines_adjacent == 0:
				board.toggle_adjacent(self)
			board.safe_left -= 1
		
		match state:
			State.NUMBER: text = str(mines_adjacent)
			State.MINE: text = '*'
	if board.safe_left <= 0:
		board.emit_signal('game_won')


func flag(value = true):
	if flagged == value:
		return
	flagged = value
	var sum = 0
	if flagged:
		text = '?'
		sum += 1
	else:
		text = ''
		sum -= 1
	for cell in board.get_adjacent(self):
		cell.flagged_adjacent += sum
	board.emit_signal('cell_flagged', flagged)


func is_flagged():
	return flagged


func mines_around():
	var cant = 0
	for cell in board.get_adjacent(self):
		if cell.state == State.MINE:
			cant += 1
	return cant