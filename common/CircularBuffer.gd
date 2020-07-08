class_name CircularBuffer

class Iterator:
	var _values
	var _values_size
	var _start
	var _curr
	var _remaining = 0

	func _init(values, start):
		_values = values
		_values_size = values.size()
		_start = start

	func should_continue():
		return _remaining > 0

	func _iter_init(arg):
		_curr = _start
		_remaining = _values_size
		return should_continue()

	func _iter_next(arg):
		_curr = (_curr + 1) % _values_size
		_remaining -= 1
		return should_continue()

	func _iter_get(arg):
		return _values[_curr]

var _max_size = 0
var _values = []
var _first = 0
var _last = -1

func _init(max_size: int = 100):
	_max_size = max_size

func iter() -> Iterator:
	return Iterator.new(_values, _first)

func append(value) -> void:
	var values_size = _values.size()
	if values_size < _max_size:
		_values.append(value)
	else:
		_values[_first] = value
		_last = _first
		_first = (_first + 1) % values_size


func _to_string() -> String:
	var result = "["
	var first = true
	for value in iter():
		if !first:
			result += ", "
		result += str(value)
		first = false
	result += "]"
	return result
