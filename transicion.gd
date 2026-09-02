extends CanvasLayer

@onready var color_rect = $ColorRect

func _ready() -> void:
	# Nos aseguramos de que el jugador pueda hacer clic al empezar
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Que el rombo esté abierto
	color_rect.material.set_shader_parameter("progress", 0.0) 

func cambiar_escena(ruta_escena: String) -> void:
	# 1. Bloqueamos los clics para que el jugador no toque nada mientras carga
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 2. Cerramos el rombo (animamos el progress de 0 a 1)
	var tween_cerrar = create_tween()
	tween_cerrar.tween_property(color_rect.material, "shader_parameter/progress", 1.0, 0.5)
	
	await tween_cerrar.finished # Esperamos a que la pantalla esté negra
	
	# 3. Cambiamos de escena en la oscuridad (¡nadie se da cuenta!)
	get_tree().change_scene_to_file(ruta_escena)
	
	# 4. Abrimos el rombo en el nuevo nivel (de 1 a 0)
	var tween_abrir = create_tween()
	tween_abrir.tween_property(color_rect.material, "shader_parameter/progress", 0.0, 0.5)
	
	await tween_abrir.finished
	
	# 5. Volvemos a permitir los clics
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
