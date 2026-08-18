extends Control

func _ready() -> void:
	$VBoxContainer/MonedasText.text = "Monedas: " + str(Global.monedas)
	$VBoxContainer/TiempoText.text = "Tiempo: " + str(Global.tiempo_final) + "s"
	$VBoxContainer/PuntajeText.text = "PUNTUACIÓN TOTAL: " + str(Global.puntaje_total)

func _on_boton_siguiente_pressed() -> void:
	Global.reiniciar_estadisticas() # Llamamos a tu función para limpiar todo
	get_tree().change_scene_to_file("res://Levels/Lvl1.tscn")
