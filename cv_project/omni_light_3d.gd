extends OmniLight3D

func _process(delta):
	var flicker_intensity = 0.9 + randf() * 0.2  # Random value between 0.9 and 1.1
	light_energy = flicker_intensity  # Update the light's energy
