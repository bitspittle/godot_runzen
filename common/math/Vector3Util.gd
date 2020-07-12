class_name Vector3Util

# Return the magnitude of b projected onto a.
#
# Will be positive if they're in the same direction, or negative otherwise
static func proj_len(a: Vector3, b: Vector3) -> float:
	var a_magnitude_squared = a.length_squared()
	if a_magnitude_squared == 0.0:
		return 0.0
	return b.dot(a) / a_magnitude_squared

# Return a vector which is b projected onto a.
#
# In other words, the result will be aligned with vector a but a different magnitude
static func proj(a: Vector3, b: Vector3) -> Vector3:
	 return proj_len(a, b) * a
