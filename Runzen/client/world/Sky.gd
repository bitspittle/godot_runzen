extends Spatial

onready var _pivot = $Pivot
onready var _sun_light = $Pivot/Sun/DirectionalLight
onready var _moon_light = $Pivot/Moon/DirectionalLight

const _SKY_COLOR_NOON = Color(0.5, 0.82, 0.86)
const _SKY_COLOR_DUSK = Color(1.0, 0.83, 0.65)
const _SKY_COLOR_NIGHT = Color(0.1, 0.1, 0.44)

const _ENERGY_DAY = 1.0
const _ENERGY_NIGHT = 0.1

var _MAX_TIME_OF_DAY = _to_time(24)
var _TIME_MORNING = _to_time(0)
var _TIME_NOON = _to_time(6)
var _TIME_PRE_DUSK = _to_time(11)
var _TIME_DUSK = _to_time(12)
var _TIME_POST_DUSK = _to_time(14)
var _TIME_NIGHT = _to_time(15)
var _TIME_MIDNIGHT = _to_time(18)

var _time_of_day = _TIME_PRE_DUSK

const _MAX_ORBIT_TILT = (PI / 2.0) / 3.0
var _day = 0 # As days pass, orbit goes from exactly around equator to slightly tilted

const _TIME_ELAPSED_MULTIPLIER = 60.0 * 60.0 # Every real second, this may seconds pass in game

static func _to_time(hour: float) -> float:
	return hour * 60.0 * 60.0

func _process(delta):
	_time_of_day += delta * _TIME_ELAPSED_MULTIPLIER
	if (_time_of_day > _MAX_TIME_OF_DAY):
		_day += 1
		_time_of_day -= _MAX_TIME_OF_DAY
		# Slowly tweak orbit angle
		# 0 days: sin(day) -> 0
		# 90 days: sin(day) -> 1
		# 180 days: sin(day) -> 0
		# 270 days: sin(day) -> -1
		_pivot.rotation.x = _MAX_ORBIT_TILT * sin(deg2rad(_day))
	
	_pivot.rotation.z = (_time_of_day / _MAX_TIME_OF_DAY) * 2 * PI

	var sky_color: Color
	if _time_of_day <= _TIME_NOON:
		sky_color = _SKY_COLOR_NIGHT.linear_interpolate(_SKY_COLOR_NOON, (_time_of_day - _TIME_MORNING) / (_TIME_NOON - _TIME_MORNING))
	elif _time_of_day <= _TIME_PRE_DUSK:
		sky_color = _SKY_COLOR_NOON
	elif _time_of_day <= _TIME_DUSK:
		sky_color = _SKY_COLOR_NOON.linear_interpolate(_SKY_COLOR_DUSK, (_time_of_day - _TIME_PRE_DUSK) / (_TIME_DUSK - _TIME_PRE_DUSK))
	elif _time_of_day <= _TIME_POST_DUSK:
		sky_color = _SKY_COLOR_DUSK.linear_interpolate(_SKY_COLOR_NIGHT, (_time_of_day - _TIME_DUSK) / (_TIME_POST_DUSK - _TIME_DUSK))
	else: # _time_of_day <= _TIME_MORNING:
		sky_color = _SKY_COLOR_NIGHT
		
	var energy_scale = abs(sin(_pivot.rotation.z))
	energy_scale = energy_scale * energy_scale # Fall off faster on the sides
	var _show_day_light = _time_of_day <= _TIME_DUSK
	_sun_light.light_energy = energy_scale * _ENERGY_DAY if _show_day_light else 0.0
	_moon_light.light_energy = energy_scale * _ENERGY_NIGHT if !_show_day_light else 0.0
	_sun_light.shadow_enabled = _show_day_light
	_moon_light.shadow_enabled = !_show_day_light
		
	get_world().fallback_environment.background_color = sky_color
	get_world().fallback_environment.ambient_light_energy = 0.02 + 0.05 * energy_scale
	get_world().fallback_environment.background_energy = 0.0
