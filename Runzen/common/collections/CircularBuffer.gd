class_name CircularBuffer

class Iterator:
	var _values
	var _values_size
	var _start
	var _curr
	var _count
	var _remaining

	func _init(values, start, count):
		_values = values
		_values_size = values.size()
		_count = count
		_start = start

	func should_continue():
		return _remaining > 0

	func _iter_init(arg):
		_curr = _start
		_remaining = _count
		return should_continue()

	func _iter_next(arg):
		_curr = (_curr + 1) % _values_size
		_remaining -= 1
		return should_continue()

	func _iter_get(arg):
		return _values[_curr]

var _values = []
var _first = 0
var _next = 0
var _size = 0

func _init(capacity: int = 100):
	for i in range(capacity):
		_values.append(null)

func iter() -> Iterator:
	return Iterator.new(_values, _first, _size)

func capacity() -> int:
	return _values.size()

func size() -> int:
	return _size

func is_empty() -> bool:
	return _size == 0
	
func is_full() -> bool:
	return size() == capacity()

func get_item(index: int):
	if index >= _size || index < -_size:
		push_error("Invalid index for circular buffer get: " + str(index))

	if index < 0:
		index += _size

	return _values[(_first + index) % _values.size()]

func remove_first():
	if is_empty():
		push_error("Cannot call remove_first on empty buffer")

	var value = _values[_first]
	_first = (_first + 1) % _values.size()
	_size -= 1
	return value

func remove_last():
	if is_empty():
		push_error("Cannot call remove_last on empty buffer")

	var last = _next - 1
	if last < 0:
		last += _values.size()

	var value = _values[last]
	_next = last
	_size -= 1
	return value

func append(value) -> void:
	_values[_next] = value
	_next = (_next + 1) % _values.size()
	_size += 1
	var cap = capacity()
	if _size > cap:
		_size = cap
		_first = (_first + 1) % cap

func clear() -> void:
	_first = 0
	_next = 0
	_size = 0

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
