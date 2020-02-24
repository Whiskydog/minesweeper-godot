extends Control

onready var grid = $CenterContainer/Grid
onready var debug_label = $ButtonGridPosition


func _ready():
	var reset_label = $Reset
	reset_label.margin_bottom -= grid.rect_size.y / 2 + reset_label.rect_size.y / 2
	reset_label.margin_top -= grid.rect_size.y / 2 + reset_label.rect_size.y / 2