extends Label

func _ready() -> void:
	# 1. Empezamos con el texto totalmente invisible (Alpha en 0)
	modulate.a = 0.0
	
	# Le damos un segundito de espera al entrar a la sala antes de que salga el texto
	await get_tree().create_timer(1.0).timeout
	
	# 2. Creamos la animación
	var tween = create_tween()
	
	# Aparecer (Pasa el Alpha a 1 en 1.5 segundos)
	tween.tween_property(self, "modulate:a", 1.0, 1.5)
	
	# Quedarse en pantalla por 2 segundos
	tween.tween_interval(2.0)
	
	# Desaparecer (Pasa el Alpha a 0 en 1.5 segundos)
	tween.tween_property(self, "modulate:a", 0.0, 1.5)
	
	# Cuando termine toda la animación, borramos el texto para ahorrar memoria
	tween.finished.connect(queue_free)
