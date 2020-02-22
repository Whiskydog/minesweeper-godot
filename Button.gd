extends Button

enum State { NUMBER, MINE }

onready var grid = get_parent()

var grid_pos = { row = 0, column = 0 }
var mines_adjacent = 0
var unavailable = false setget set_unavailable
var flagged = false setget flag, is_flagged
var state

signal mouse_has_entered


func _init(size, row, column):
	._init()
	grid_pos.row = row
	grid_pos.column = column
	toggle_mode = true
	rect_min_size = Vector2.ONE * size
	focus_mode = FOCUS_NONE
	mouse_filter = MOUSE_FILTER_IGNORE
	align = Button.ALIGN_CENTER


func _ready():
	connect('mouse_entered', self, '_on_mouse_entered')


func grid_pos_to_string():
	return str(grid_pos.row) + ', ' + str(grid_pos.column)


func _on_mouse_entered():
	emit_signal('mouse_has_entered', self)


func has_mine_around():
	for button in grid.get_adjacent(self):
		if button.is_mine():
			return true
	return false


func toggle_adjacent():
	for button in grid.get_adjacent(self):
		if not button.is_mine() and not button.unavailable:
			button.unavailable = true


func is_mine():
	return state == State.MINE


func set_unavailable(value):
	unavailable = value
	if unavailable:
		if not pressed:
			pressed = true
		if mines_adjacent == 0 and not is_mine():
			toggle_adjacent()
		elif is_mine() and not Global.game.game_over:
			grid.emit_signal('toggled_mine')
		match state:
			State.NUMBER: text = str(mines_adjacent)
			State.MINE: text = '*'



func flag(value):
	flagged = value
	if flagged:
		text = '?'
	else:
		text = ''


func is_flagged():
	return flagged
