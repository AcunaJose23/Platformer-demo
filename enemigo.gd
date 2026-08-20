extends CharacterBody2D

# --- CONFIGURACIÓN DE VELOCIDADES ---
var speed_patrulla = 50.0
var speed_embestida = 120.0 

# --- VARIABLES DE EMBESTIDA ---
var embistiendo = false
var direccion_embestida = 0 # Guardará 1 (derecha) o -1 (izquierda)

# --- VARIABLES DE PATRULLA ---
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
	if embistiendo:
		# ==============================
		#       MODO EMBESTIDA
		# ==============================
		# Corremos usando la dirección que guardamos ciegamente
		velocity.x = direccion_embestida * speed_embestida
		
		# Voltear Sprite al embestir
		if direccion_embestida > 0:
			$AnimatedSprite2D.flip_h = false
		elif direccion_embestida < 0:
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

# Cuando el Player entra a la zona de visión grande (Lo ve y activa la trampa)
func _on_zona_vision_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not embistiendo:
		embistiendo = true
		
		# Guardamos si el Player está a la derecha (1) o izquierda (-1) en ese milisegundo
		direccion_embestida = sign(body.global_position.x - global_position.x)
		
		# Por si están exactamente en el mismo pixel
		if direccion_embestida == 0:
			direccion_embestida = 1
			
		print("¡Embestida activada hacia: ", direccion_embestida, "!")

# Cuando el Player sale de la zona de visión grande
func _on_zona_vision_body_exited(_body: Node2D) -> void:
	# Lo dejamos vacío con 'pass'. Así NUNCA dejará de correr hasta caer al vacío.
	pass





func _on_daño_body_entered(body: Node2D) -> void:
	if  body.name == "Player":
		body.lose_health(global_position.x)


func _on_area_destruccion_body_entered(body: Node2D) -> void:
	print("si")
	if embistiendo and body.has_method("romper"):
		body.romper()
