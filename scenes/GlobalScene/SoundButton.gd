extends TextureButton

var sound_on = true

var textures: Dictionary = {
	'on': {
		'normal': load("res://assets/icons/sound-on.png"),
		'hover': load("res://assets/icons/sound-on-hover.png"),
		'pressed': load("res://assets/icons/sound-on-pressed.png"),
	},
	'off': {
		'normal': load("res://assets/icons/sound-off.png"),
		'hover': load("res://assets/icons/sound-off-hover.png"),
		'pressed': load("res://assets/icons/sound-off-pressed.png"),
	}
}


func _on_pressed():
	sound_on = not sound_on
	
	var tex = textures['on' if sound_on else 'off']
	texture_normal = tex['normal']
	texture_hover = tex['hover']
	texture_pressed = tex['pressed']
