extends GridContainer

export(float, 20.0, 999.0) var button_size = 20.0
export(int) var rows = 1
export(int) var max_mine_count = 10

var mine_count = 0
var input = {
	'last_but': null,
	'cur_but': null,
	'mb_left': false,
	'mb_right': false
}

signal toggled_mine


func _ready():
	_initialize()


func _gui_input(event):
	if event is InputEventMouse:
		input.last_but = input.cur_but
		input.cur_but = get_button_at_local_pos(event.position)
		input.mb_left = event.button_mask == BUTTON_LEFT
		input.mb_right = event.button_mask == BUTTON_RIGHT
		_process_mouse()
		

func _process_mouse():
	if input.cur_but != null:
		if input.cur_but.unavailable:
			press_adjacent(input.cur_but, input.mb_left)
		elif input.mb_left and not input.cur_but.pressed and not input.cur_but.is_flagged():
			input.cur_but.pressed = true
		elif not input.mb_left and input.cur_but.pressed:
			if not input.cur_but.unavailable:
				if not Global.game.first_move_done:
					_init_board()
				input.cur_but.unavailable = true
		elif input.mb_right:
			input.cur_but.flag(not input.cur_but.is_flagged())
	if input.last_but != null and input.last_but != input.cur_but:
		press_adjacent(input.last_but, false)
		if not input.last_but.unavailable:
			input.last_but.pressed = false


func _init_board():
	Global.game.first_move_done = true
	_place_mines()
	_place_numbers()


func _place_numbers():
	for button in get_children():
		if button.is_mine():
			continue
		for adj in get_adjacent(button):
			if adj.is_mine():
				button.mines_adjacent += 1
		if button.mines_adjacent > 0:
			button.state = button.State.NUMBER


func _place_mines():
	for button in get_children():
		if button == input.cur_but:
			continue
		if randf() < .15 and mine_count < max_mine_count:
			button.state = button.State.MINE
			mine_count += 1


func _initialize():
	for i in range(columns * rows):
		var row = i / columns
		var column = posmod(i, columns)
		var button = preload('res://Button.gd').new(button_size, row, column)
		add_child(button, true)
		button.owner = self


func get_button(row, column):
	if (row < 0 or column < 0) or (row > rows - 1 or column > columns - 1):
		return
	var index = row * columns + column
	return get_child(index)


func get_button_at_local_pos(local_pos):
	for button in get_children():
		if button.get_rect().has_point(local_pos):
			return button


func get_adjacent(button):
	var array = []
	for i in range(-1, 2):
		for j in range(-1, 2):
			var b = get_button(button.grid_pos.row + i, button.grid_pos.column + j)
			if b != null and b != button:
				array.append(b)
	return array


func press_adjacent(button, pressed):
	for adj in get_adjacent(button):
		if not adj.unavailable and not adj.is_flagged():
			adj.pressed = pressed


func reveal_mines():
	for b in get_children():
		if b.is_mine() and not b.is_flagged():
			b.unavailable = true
