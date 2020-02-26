extends GridContainer

export(float, 20.0, 999.0) var cell_size = 20.0
export(int) var rows = 1
export(int) var mine_count = 10

var Cell = preload('res://Cell.gd')
var input = {
	'last_cell': null,
	'cur_cell': null,
	'mb_pressed': false,
	'mb_left': false,
	'mb_right': false,
	'motion': false
}

var safe_left: int

signal game_won
signal toggled_mine
signal first_move_done
signal cell_flagged


func _ready():
	_initialize()
	connect('game_won', self, '_on_game_won')
	connect('toggled_mine', self, '_on_toggled_mine')
	connect('first_move_done', self, '_on_first_move_done')



func _gui_input(event):
	if event is InputEventMouse:
		input.last_cell = input.cur_cell
		input.cur_cell = get_cell_at_local_pos(event.position)
		if event is InputEventMouseMotion:
			input.motion = true
			input.mb_left = event.button_mask == BUTTON_LEFT
			input.mb_right = event.button_mask == BUTTON_RIGHT
		elif event is InputEventMouseButton:
			input.motion = false
			input.mb_left = event.button_index == BUTTON_LEFT
			input.mb_right = event.button_index == BUTTON_RIGHT
			input.mb_pressed = event.pressed
		_process_mouse()
		

func _process_mouse():
	if input.cur_cell != null:
		if input.mb_left:
			if input.cur_cell.unavailable:
				press_adjacent(input.cur_cell)
			elif input.mb_pressed and not input.cur_cell.pressed and not input.cur_cell.is_flagged():
				input.cur_cell.pressed = true
			elif not input.mb_pressed and input.cur_cell.pressed:
				if is_connected('first_move_done', self, '_on_first_move_done'):
					emit_signal('first_move_done')
				input.cur_cell.set_unavailable()
		elif not input.motion and input.mb_right and not input.cur_cell.unavailable and input.mb_pressed:
			if is_connected('first_move_done', self, '_on_first_move_done'):
				emit_signal('first_move_done')
			input.cur_cell.flag(not input.cur_cell.is_flagged())
	if input.last_cell != null and input.last_cell != input.cur_cell:
		press_adjacent(input.last_cell, false)
		if not input.last_cell.unavailable:
			input.last_cell.pressed = false


func press_adjacent(cell, pressed = input.mb_pressed):
	for adj in get_adjacent(cell):
		if not adj.is_flagged() and cell.flagged_adjacent != 0 and cell.flagged_adjacent >= cell.mines_adjacent and not input.mb_right and input.mb_left and not pressed:
			adj.set_unavailable()
		elif not adj.unavailable:
			if not adj.is_flagged():
				adj.pressed = pressed


func _init_board():
	_place_mines()
	_place_numbers()


func _place_numbers():
	for cell in get_children():
		if cell.is_mine():
			continue
		for adj in get_adjacent(cell):
			if adj.is_mine():
				cell.mines_adjacent += 1
		if cell.mines_adjacent > 0:
			cell.state = Cell.State.NUMBER


func _place_mines():
	while mine_count > 0:
		var row = randi() % rows
		var col = randi() % columns
		var cell = get_cell(row, col)
		if cell.state != Cell.State.MINE:
			cell.state = Cell.State.MINE
			mine_count -= 1
	
	if not input.mb_right and input.cur_cell.state == Cell.State.MINE:
		input.cur_cell.state = 0
		var i = 0
		while get_child(i).state == Cell.State.MINE:
			i += 1
		get_child(i).state = Cell.State.MINE



func _initialize():
	var difficulty = Settings.get_setting('game', 'difficulty')
	rows = difficulty.rows
	columns = difficulty.columns
	mine_count = difficulty.mine_count
	safe_left = rows * columns - mine_count

	for i in range(columns * rows):
		var row = i / columns
		var column = posmod(i, columns)
		var cell = Cell.new(cell_size, row, column)
		add_child(cell, true)
		cell.owner = self


func get_cell(row, column):
	if (row < 0 or column < 0) or (row > rows - 1 or column > columns - 1):
		return
	var index = row * columns + column
	return get_child(index)


func get_cell_at_local_pos(local_pos):
	for cell in get_children():
		if cell.get_rect().has_point(local_pos):
			return cell


func get_adjacent(cell):
	var array = []
	for i in range(-1, 2):
		for j in range(-1, 2):
			var b = get_cell(cell.board_pos.row + i, cell.board_pos.column + j)
			if b != null and b != cell:
				array.append(b)
	return array


func reveal_mines():
	for b in get_children():
		if b.is_mine() and not b.is_flagged():
			b.set_unavailable()


func _on_toggled_mine():
	mouse_filter = MOUSE_FILTER_IGNORE
	reveal_mines()


func _on_first_move_done():
	disconnect('first_move_done', self, '_on_first_move_done')
	_init_board()


func _on_game_won():
	for cell in get_children():
		if not cell.is_mine():
			cell.set_unavailable()
		else:
			cell.flag()
	mouse_filter = MOUSE_FILTER_IGNORE
