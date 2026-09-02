extends Control

func _on_button_pressed() -> void:
	# 1. Le devolvemos sus corazones mágicamente para su próxima partida
	Global.corazones = 3.0 
	
	# 2. Ahora sí, lo mandamos al menú animado que arreglaste
	Transicion.cambiar_escena("res://MenuPrincipal.tscn")
