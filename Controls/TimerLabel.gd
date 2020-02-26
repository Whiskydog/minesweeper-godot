extends Label

var counter = 0


func _ready():
	set_process(false)


func _process(delta):
	counter += delta
	update_text()


func start():
	set_process(true)


func stop():
	set_process(false)


func update_text():
	text = '%03d' % int(counter)
