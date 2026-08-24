extends AnimatableBody2D

func _on_pincho_1_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.lose_health()
func _on_pincho_2_body_entered(body: Node2D) -> void:
		if body.name == "Player":
			body.lose_health()
func _on_pincho_3_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.lose_health()
func _on_pincho_4_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.lose_health()

# Ajusta estas posiciones según el tamaño de tu sala
var pos_izquierda = Vector2(-267, 151) 
var pos_derecha = Vector2(236, 151)

func _ready() -> void:
	# La cola empieza escondida a la izquierda
	global_position = pos_izquierda

# Llama a esta función cuando el jefe decida hacer este ataque
func ataque_barrido() -> void:
	# Creamos la animación por código
	var tween = create_tween()
	
	# 1. Va hacia la derecha (Tarda 3.0 segundos, ajusta la velocidad aquí)
	tween.tween_property(self, "global_position", pos_derecha, 4.0)
	
	# 2. Se detiene 0.5 segundos en la pared derecha (para que el jugador respire)
	tween.tween_interval(1.5)
	
	# 3. ¡Se devuelve a la izquierda!
	tween.tween_property(self, "global_position", pos_izquierda, 4.0)
	
	# Opcional: Avisar cuando el ataque termina para que el jefe haga otra cosa
	tween.finished.connect(termino_el_ataque)

func termino_el_ataque() -> void:
	print("El ataque de la cola terminó, el jefe vuelve a su estado normal.")
	
func _process(_delta: float) -> void:
	# MODO DE PRUEBA: Presiona la tecla "Enter" o "Espacio" para iniciar el ataque
	if Input.is_action_just_pressed("ui_accept"):
		print("¡Iniciando ataque de prueba!")
		ataque_barrido()
