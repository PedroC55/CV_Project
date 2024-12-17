extends Node3D # Use Node2D se estiver trabalhando em 2D

# Tempo mínimo e máximo entre os flashes
@export_range(0.1, 2.0)
var min_flicker_time: float = 0.1
@export_range(0.1, 2.0)
var max_flicker_time: float = 0.5

# Lista para armazenar todas as luzes
var lights: Array = []

func _ready():
	# Obtenha todas as luzes filhas deste nó
	for child in get_children():
		if child is OmniLight3D: # Ou Light2D para 2D
			lights.append(child)
			
	print(lights)
	
	# Comece a piscar
	flicker_lights()

func flicker_lights():
	while true:
		# Alterna o estado de todas as luzes simultaneamente
		for light in lights:
			light.visible = !light.visible  # Alternar visibilidade
			# Ou ajustar a intensidade (para Light3D)
			# light.energy = 4 if light.visible else 0

		# Aguarda um intervalo de tempo aleatório
		var next_flicker_time = randf_range(min_flicker_time, max_flicker_time)
		await get_tree().create_timer(next_flicker_time).timeout
