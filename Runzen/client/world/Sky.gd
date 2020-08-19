extends Spatial

onready var _pivot = $Pivot

const _SKY_COLOR_NOON = Color(0.5, 0.82, 0.86)
const _SKY_COLOR_DUSK = Color(1.0, 0.83, 0.65)
const _SKY_COLOR_NIGHT = Color(0.1, 0.1, 0.44)

var _MAX_TIME_OF_DAY = _to_time(24)
var _time_of_day = _to_time(0)
var _TIME_NOON = 0.0
var _TIME_PRE_DUSK = _to_time(5)
var _TIME_DUSK = _to_time(6)
var _TIME_NIGHT = _to_time(9)
var _TIME_MORNING = _to_time(18)

const _TIME_ELAPSED_MULTIPLIER = 60.0 * 60.0 # Every real second, this may seconds pass in game

static func _to_time(hour: int) -> float:
	return hour * 60.0 * 60.0

func _process(delta):
	_time_of_day += delta * _TIME_ELAPSED_MULTIPLIER
	if (_time_of_day > _MAX_TIME_OF_DAY):
		_time_of_day -= _MAX_TIME_OF_DAY
	
	_pivot.rotation.z = (_time_of_day / _MAX_TIME_OF_DAY) * 2 * PI

	var sky_color: Color
	if _time_of_day <= _TIME_PRE_DUSK:
		sky_color = _SKY_COLOR_NOON
	elif _time_of_day <= _TIME_DUSK:
		sky_color = _SKY_COLOR_NOON.linear_interpolate(_SKY_COLOR_DUSK, (_time_of_day - _TIME_PRE_DUSK) / (_TIME_DUSK - _TIME_PRE_DUSK))
	elif _time_of_day <= _TIME_NIGHT:
		sky_color = _SKY_COLOR_DUSK.linear_interpolate(_SKY_COLOR_NIGHT, (_time_of_day - _TIME_DUSK) / (_TIME_NIGHT - _TIME_DUSK))
	elif _time_of_day <= _TIME_MORNING:
		sky_color = _SKY_COLOR_NIGHT
	else:
		sky_color = _SKY_COLOR_NIGHT.linear_interpolate(_SKY_COLOR_NOON, (_time_of_day - _TIME_MORNING) / (_MAX_TIME_OF_DAY - _TIME_MORNING))
		
	get_world().fallback_environment.background_color = sky_color
#	_pivot.rotate_z(0.5 * delta)
#
#	var i = _pivot.rotation.z * 128
#
#	var new_color = Color(i / 255.0, 0.0, 0.0)
#	print(new_color)
#	_pivot.get_world().fallback_environment.background_color = new_color
	
