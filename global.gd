extends Node

var monedas: int = 0
#espada
var espada: bool = false
var tiempo_final: int = 0
var puntaje_total: int = 0
var corazones: float = 3.0

var nivel_destino: String = ""

# --- VARIABLES DEL EASTER EGG ---
# El arreglo con el Código Konami usando las teclas físicas del teclado
var codigo_konami = [
	KEY_UP, KEY_UP, KEY_DOWN, KEY_DOWN, 
	KEY_LEFT, KEY_RIGHT, KEY_LEFT, KEY_RIGHT, 
	KEY_B, KEY_A
]
var indice_konami = 0 # Para llevar la cuenta de cuántas teclas lleva bien

# --- DETECTOR DE TECLAS INVISIBLE ---
func _input(event: InputEvent) -> void:
	# Verificamos que sea un botonazo del teclado, que esté presionado, y que no sea dejar la tecla pegada
	if event is InputEventKey and event.pressed and not event.echo:
		
		# Si la tecla que tocó es la que sigue en el código...
		if event.keycode == codigo_konami[indice_konami]:
			indice_konami += 1 # Avanza al siguiente paso
			
			# Si llegó al final de la lista... ¡Premio!
			if indice_konami == codigo_konami.size():
				activar_secreto()
				indice_konami = 0 # Reiniciamos por si lo quiere hacer de nuevo
				
		else:
			# Si se equivoca de tecla, rompe la cadena y vuelve a empezar
			# (Pero si la tecla equivocada fue "Arriba", empezamos en el paso 1)
			if event.keycode == codigo_konami[0]:
				indice_konami = 1
			else:
				indice_konami = 0

# --- LA MAGIA DEL EASTER EGG ---
func activar_secreto() -> void:
	print("¡CÓDIGO KONAMI ACTIVADO!")
	
	espada = true # Le damos el arma
	corazones = 3.0 # Le curamos la vida entera por si acaso
	
	# Asegúrate de poner el nombre exacto de la escena de tu jefe aquí
	Transicion.cambiar_escena("res://prueba_boss.tscn")

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
	get_tree().change_scene_to_file(ruta_escena)

# En el futuro, llamarás a esta función cuando el jugador salga 
# de la pantalla de puntajes y empiece el Nivel 2
func reiniciar_estadisticas() -> void:
	monedas = 0
	tiempo_final = 0
	puntaje_total = 0
