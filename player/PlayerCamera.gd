extends Camera2D

var shakeStrength: float = 7.0
var shakeFade: float = 4.0

var _rng = RandomNumberGenerator.new()
var _currentShakeStrength: float = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _currentShakeStrength > 0:
		_currentShakeStrength = lerpf(_currentShakeStrength, 0, shakeFade * delta)
		
	offset = randomOffset()


func shake():
	_currentShakeStrength = shakeStrength
	
func randomOffset() -> Vector2:
	return Vector2(
		_rng.randf_range(-_currentShakeStrength, _currentShakeStrength),
		_rng.randf_range(-_currentShakeStrength, _currentShakeStrength)
	)
