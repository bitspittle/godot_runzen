extends Panel

var history: CircularBuffer = null

onready var _quarter = get_viewport_rect().size.y / 4
onready var _half = get_viewport_rect().size.y / 2
onready var _three_quarters = get_viewport_rect().size.y * 3 / 4
onready var _width = get_viewport_rect().size.x

var _paused = false

func _process(delta):
	if !_paused:
		update()

func _draw():
	var history = Accel.deltas
	if history.size() < 2:
		return

	var x0 = 0
	var y0 = _quarter
	var x1 = 0
	var y1 = _quarter
	var i = 0

	for item in history.iter():
		var acc: Vector3 = item
		if i == 0:
			y0 = _quarter + acc.x
		else:
			x1 = x0 + (_width / (history.capacity() - 1))
			y1 = _quarter + acc.x
			draw_line(Vector2(x0, y0), Vector2(x1, y1), Color.red)
			x0 = x1
			y0 = y1
		i += 1

	x0 = 0
	y0 = _half
	x1 = 0
	y1 = _half
	i = 0

	for item in history.iter():
		var acc: Vector3 = item
		if i == 0:
			y0 = _half + acc.y
		else:
			x1 = x0 + (_width / (history.capacity() - 1))
			y1 = _half + acc.y
			draw_line(Vector2(x0, y0), Vector2(x1, y1), Color.green)
			x0 = x1
			y0 = y1
		i += 1

	x0 = 0
	y0 = _three_quarters
	x1 = 0
	y1 = _three_quarters
	i = 0

	for item in history.iter():
		var acc: Vector3 = item
		if i == 0:
			y0 = _three_quarters + acc.z
		else:
			x1 = x0 + (_width / (history.capacity() - 1))
			y1 = _three_quarters + acc.z
			draw_line(Vector2(x0, y0), Vector2(x1, y1), Color.blue)
			x0 = x1
			y0 = y1
		i += 1


func _on_Button_toggled(button_pressed):
	_paused = button_pressed
