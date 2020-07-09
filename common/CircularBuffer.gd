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

var _capacity = 0
var _values = []
var _first = 0
var _last = -1

func _init(capacity: int = 100):
	_capacity = capacity

func iter() -> Iterator:
	return Iterator.new(_values, _first)

func capacity() -> int:
	return _capacity

func size() -> int:
	return _values.size()

func empty() -> bool:
	return size() == 0

func get_item(index: int):
	var size = size()
	if index >= size || index < -size:
		push_error("Invalid index for circular buffer get: " + str(index))

	if index < 0:
		index += size

	return _values[(_first + index) % size]

func append(value) -> void:
	var values_size = _values.size()
	if values_size < _capacity:
		_values.append(value)
	else:
		_values[_first] = value
		_last = _first
		_first = (_first + 1) % values_size

func clear() -> void:
	_values.clear()
	_first = 0
	_last = -1

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
