extends GridContainer

export(float, 20.0, 999.0) var cell_size = 20.0
export(int) var rows = 1
export(int) var mine_count = 10

#var input = {
#	'last_cell': null,
#	'cur_cell': null,
#	'mb_pressed': false,
#	'mb_left': false,
#	'mb_right': false,
#	'motion': false
#}

var last_cell_on_mouse: Cell
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
		var cell = get_cell_at_local_pos(event.position)
		if event is InputEventMouseButton:
			_process_mouse_button(event as InputEventMouseButton, cell)
		else:
			_process_mouse_motion(event as InputEventMouseMotion, cell)
		last_cell_on_mouse = cell


func _process_mouse_button(event: InputEventMouseButton, cell: Cell):
	if event.button_index == BUTTON_LEFT or event.button_index == BUTTON_RIGHT:
		if is_connected('first_move_done', self, '_on_first_move_done'):
			emit_signal('first_move_done', cell)
		if event.button_index == BUTTON_LEFT:
			if not cell.flagged:
				if event.pressed:
					cell.pressed = true
				else:
					cell.set_unavailable()
			if cell.unavailable:
				press_adjacent(cell, event.pressed)
		elif event.button_index == BUTTON_RIGHT:
			if event.pressed:
				if not cell.unavailable:
					cell.flag(not cell.flagged)


func _process_mouse_motion(event: InputEventMouseMotion, cell: Cell):
	if event.button_mask == BUTTON_LEFT:
		if last_cell_on_mouse != null:
			if last_cell_on_mouse != cell:
					if not last_cell_on_mouse.unavailable:
						last_cell_on_mouse.pressed = false
					else:
						press_adjacent(last_cell_on_mouse, false)
		if cell.unavailable:
			press_adjacent(cell, true)
		else:
			if not cell.flagged:
				cell.pressed = true


func press_adjacent(cell, pressed):
	for adj in get_adjacent(cell):
		if not adj.unavailable:
			if not adj.flagged:
				adj.pressed = pressed
				if not pressed:
					if cell.flagged_adjacent != 0:
						if cell.flagged_adjacent >= cell.mines_adjacent:
							adj.unavailable = true


func _init_board(initial_cell):
	_place_mines(initial_cell)
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


func _place_mines(initial_cell):
	while mine_count > 0:
		var row = randi() % rows
		var col = randi() % columns
		var cell = get_cell(row, col)
		if cell.state != Cell.State.MINE:
			cell.state = Cell.State.MINE
			mine_count -= 1

	if not initial_cell.flagged:
		if initial_cell.state == Cell.State.MINE:
			initial_cell.state = 0
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


func _on_first_move_done(initial_cell):
	disconnect('first_move_done', self, '_on_first_move_done')
	_init_board(initial_cell)


func _on_game_won():
	for cell in get_children():
		if not cell.is_mine():
			cell.set_unavailable()
		else:
			cell.flag()
	mouse_filter = MOUSE_FILTER_IGNORE


func toggle_adjacent(cell):
	for adj in get_adjacent(cell):
		adj.set_unavailable()