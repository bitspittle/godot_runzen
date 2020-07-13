class_name OsUtils

static func is_mobile():
	# TODO: iOS
	return OS.get_name() == "Android"

static func is_debug():
	return OS.is_debug_build()

static func is_release():
	return !is_debug()
