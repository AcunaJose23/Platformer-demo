extends Control

func _ready() -> void:
	$VBoxContainer/MonedasText.text = "Monedas: " + str(Global.monedas)
	$VBoxContainer/TiempoText.text = "Tiempo: " + str(Global.tiempo_final) + "s"
	$VBoxContainer/PuntajeText.text = "PUNTUACIÓN TOTAL: " + str(Global.puntaje_total)

func _on_boton_siguiente_pressed() -> void:
	# Verificamos que el destino no esté vacío por seguridad
	if Global.nivel_destino != "":
		# Usamos la transición genial de los rombos hacia el destino guardado
		Transicion.cambiar_escena(Global.nivel_destino)
	else:
		print("Error: No se guardó ningún destino en el Global")
		# Por si acaso, lo devuelves al menú principal
		Transicion.cambiar_escena("res://MenuPrincipal.tscn")
