extends AudioStreamPlayer

@export var endSeconds: float
@export var initialDbFade: bool = true
@export var initialDbFadeAmount: float = 6
@export var initialDbFadeDurationMs = 1000.0

@onready var initialDb = self.volume_db
@onready var startFadeTimestamp = Time.get_ticks_msec()

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_db()
	self.play(0.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_set_db()
	
	if endSeconds:
		var pos = self.get_playback_position()
		if pos > endSeconds:
			self.play(0) # Start from beginning

func _set_db():
	var fadePercent = (Time.get_ticks_msec() - startFadeTimestamp) / initialDbFadeDurationMs
	if fadePercent <= 1:
		self.volume_db = initialDb - (1 - fadePercent) * initialDbFadeAmount
