extends CanvasLayer

@onready var pantalla_inicio = $PantallaInicio
@onready var pantalla_pausa = $PantallaPausa

var juego_iniciado = false

func _ready() -> void:
	# ¡LA MAGIA!: Este nodo ignorará la pausa y seguirá funcionando
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Configuramos cómo se ve todo al apenas abrir el juego
	pantalla_inicio.visible = true
	pantalla_pausa.visible = false
	
	# Congelamos el mundo entero para que el nivel no empiece
	get_tree().paused = true 

# Esta función lee las teclas en cualquier momento
func _input(event: InputEvent) -> void:
	# "ui_cancel" es la tecla Escape (Esc) por defecto
	if event.is_action_pressed("ui_cancel"):
		# Solo permitimos pausar si ya le dimos a "Jugar"
		if juego_iniciado:
			alternar_pausa()

func alternar_pausa() -> void:
	# Invertimos la pausa (Si estaba en true pasa a false, y viceversa)
	var nuevo_estado = not get_tree().paused
	get_tree().paused = nuevo_estado
	pantalla_pausa.visible = nuevo_estado

func _on_jugar_pressed() -> void:
	# Quitamos la pantalla de inicio
	pantalla_inicio.visible = false
	# Descongelamos el mundo para que el jugador caiga y se mueva
	get_tree().paused = false
	# Le avisamos al sistema que ya puede usar el botón de pausa (Esc)
	juego_iniciado = true


func _on_reanudar_pressed() -> void:
	# Simplemente llamamos a la función que ya hicimos arriba
	alternar_pausa()
