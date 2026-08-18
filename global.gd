extends Node

var monedas: int = 0
var tiempo_final: int = 0
var puntaje_total: int = 0

# Esta función hace el cálculo y guarda los datos
func calcular_puntaje(tiempo_del_jugador: float) -> void:
	tiempo_final = int(tiempo_del_jugador)
	
	var puntos_por_monedas = monedas * 50
	var penalizacion_tiempo = tiempo_final * 3
	
	puntaje_total = puntos_por_monedas - penalizacion_tiempo
	
	if puntaje_total < 0:
		puntaje_total = 0
		
	# Esto imprimirá el resultado en la consola negra de abajo para que verifiques que funciona
	print("--- CÁLCULO DE NIVEL ---")
	print("Monedas: ", monedas, " | Tiempo: ", tiempo_final, "s")
	print("Puntaje Total Guardado: ", puntaje_total)

func cambiar_nivel(ruta_escena: String) -> void:
	monedas = 0
	get_tree().change_scene_to_file(ruta_escena)

# En el futuro, llamarás a esta función cuando el jugador salga 
# de la pantalla de puntajes y empiece el Nivel 2
func reiniciar_estadisticas() -> void:
	monedas = 0
	tiempo_final = 0
	puntaje_total = 0
