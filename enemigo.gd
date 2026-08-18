extends CharacterBody2D

# --- CONFIGURACIÓN DE VELOCIDADES ---
var speed_patrulla = 50.0
var speed_persecucion = 120.0

# --- VARIABLES DE PERSECUCIÓN ---
var persiguiendo = false
var objetivo : Node2D = null

# --- VARIABLES DE PATRULLA ---
# @export nos deja elegir los nodos desde el panel Inspector
@export var punto_izquierdo: Marker2D
@export var punto_derecho: Marker2D
var destino_actual: Marker2D

func _ready() -> void:
	# Al empezar, siempre caminará primero hacia la derecha
	destino_actual = punto_derecho

func _physics_process(delta: float) -> void:
	# 1. Aplicar Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. EL CEREBRO: Decidir qué hacer
	if persiguiendo and objetivo != null:
		# ==============================
		#       MODO PERSECUCIÓN
		# ==============================
		var direccion = sign(objetivo.global_position.x - global_position.x)
		velocity.x = direccion * speed_persecucion
		
		# Voltear Sprite al perseguir
		if direccion > 0:
			$AnimatedSprite2D.flip_h = false
		elif direccion < 0:
			$AnimatedSprite2D.flip_h = true

	else:
		# ==============================
		#         MODO PATRULLA
		# ==============================
		if destino_actual != null:
			var direccion = sign(destino_actual.global_position.x - global_position.x)
			velocity.x = direccion * speed_patrulla
			
			# Voltear Sprite al patrullar
			if direccion > 0:
				$AnimatedSprite2D.flip_h = false
			elif direccion < 0:
				$AnimatedSprite2D.flip_h = true
			
			# Comprobar si ya llegamos al punto actual (< 5 píxeles de distancia)
			var distancia = abs(global_position.x - destino_actual.global_position.x)
			if distancia < 5.0:
				# Cambiar de rumbo
				if destino_actual == punto_derecho:
					destino_actual = punto_izquierdo
				else:
					destino_actual = punto_derecho
		else:
			# Si olvidaste poner los puntos en el editor, el enemigo se frena
			velocity.x = move_toward(velocity.x, 0, speed_patrulla)

	# 3. Aplicar el movimiento
	move_and_slide()

# ==============================
#      SEÑALES DE VISIÓN
# ==============================

# Cuando el Player entra a la zona (Lo ve)
func _on_zona_vision_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		persiguiendo = true
		objetivo = body

# Cuando el Player sale de la zona (Se escapa)
func _on_zona_vision_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		persiguiendo = false
		objetivo = null
