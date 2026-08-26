extends AnimatableBody2D

# --- NUEVO: Control remoto para la cabeza ---
@export var cabeza_dragon: Node2D 

# --- El seguro anti-bugs ---
var atacando = false 

func _on_pincho_1_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.lose_health(global_position.x) # Añadimos la posición para el empuje
func _on_pincho_2_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.lose_health(global_position.x)
func _on_pincho_3_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.lose_health(global_position.x)
func _on_pincho_4_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.lose_health(global_position.x)

# Ajusta estas posiciones según el tamaño de tu sala
var pos_izquierda = Vector2(-267, 151) 
var pos_derecha = Vector2(236, 151)

func _ready() -> void:
	# La cola empieza escondida a la izquierda
	global_position = pos_izquierda

func ataque_barrido() -> void:
	# Si ya está atacando, cancelamos la orden para que no se vuelva loco
	if atacando:
		return 
		
	atacando = true # Ponemos el candado
	
	# 1. Le decimos a la cabeza que se esconda
	if cabeza_dragon != null:
		cabeza_dragon.esconder()
	
	var tween = create_tween()
	
	# 2. Hacemos que la cola espere 1 segundo ANTES de salir para que la cabeza se esconda
	tween.tween_interval(1.0)
	
	# 3. Va hacia la derecha
	tween.tween_property(self, "global_position", pos_derecha, 3.0)
	
	# 4. Se detiene 0.5 segundos en la pared derecha (para que el jugador respire)
	tween.tween_interval(0.5)
	
	# 5. ¡Se devuelve a la izquierda!
	tween.tween_property(self, "global_position", pos_izquierda, 3.0)
	
	tween.finished.connect(termino_el_ataque)

func termino_el_ataque() -> void:
	atacando = false # Quitamos el candado para que pueda volver a atacar
	
	# Cuando la cola vuelve a su escondite, la cabeza vuelve a salir
	if cabeza_dragon != null:
		cabeza_dragon.aparecer()

#func _process(_delta: float) -> void:
#	# MODO DE PRUEBA: Presiona la tecla "Enter" o "Espacio" para iniciar el ataque
#	if Input.is_action_just_pressed("ui_accept"):
#		ataque_barrido()
