extends Panel

var history = CircularBuffer.new()

onready var _size = rect_size

func _process(delta):
	history.append(Input.get_accelerometer())
	update()

func _draw_horiz(y: int, color: Color):
	draw_line(Vector2(0, y), Vector2(_size.x, y), color)

func _draw():
	var baseline = _size.y / 2
	_draw_horiz(baseline, Color.gray)
	_draw_horiz(baseline - 10, Color.lightgray)
	_draw_horiz(baseline - 20, Color.lightgray)
	_draw_horiz(baseline + 10, Color.lightgray)
	_draw_horiz(baseline + 20, Color.lightgray)

	if history.size() >= 2:
		var x0 = 0
		var y0 = 0
		var x1 = x0
		var y1 = y0

		var step = _size.x / (history.capacity())
		var i = 0
		for acc in history.iter():
			var acc_len = acc.length() - 10.0
			if i == 0:
				y0 = baseline + acc_len
			else:
				x1 = i * step
				y1 = baseline + acc_len
				draw_line(Vector2(x0, y0), Vector2(x1, y1), Color.blue)
				x0 = x1
				y0 = y1
			i += 1
