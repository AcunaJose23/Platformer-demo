extends Area2D

# --- Variables de Movimiento ---
# Ajusta estos números acomodando tu Área2D en el editor
var pos_abajo = Vector2(213, 257) # Escondida debajo del suelo
var pos_arriba = Vector2(213, 43) # Visible en la parte de arriba

# --- Referencias ---
@export var escena_bola: PackedScene
@export var player: Node2D # NUEVO: Necesitamos saber dónde está el jugador para apuntarle

# --- Variables de Combate ---
var vida_jefe = 3

func _ready() -> void:
	# La cabeza empieza escondida
	position = pos_abajo
	
	# Esperamos medio segundo antes de salir para que 
	# el cambio de escena desde el NPC no congele la animación
	await get_tree().create_timer(0.5).timeout 
	
	# Y sube dramáticamente al iniciar la escena
	aparecer()

# --- Funciones de Movimiento (Controladas por la Cola) ---
func aparecer() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", pos_arriba, 1.5).set_trans(Tween.TRANS_SINE)

func esconder() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", pos_abajo, 1.0).set_trans(Tween.TRANS_SINE)

# --- Funciones de Daño ---
func _on_area_entered(area: Area2D) -> void:
	# Comprobamos si lo que chocó con nosotros es una bola de fuego Y si fue parreada
	if area.is_in_group("bola_fuego") and area.fue_parreada:
		recibir_dano()
		area.queue_free() # Destruimos la bola de fuego para que no traspase la cabeza

func recibir_dano() -> void:
	vida_jefe -= 1
	print("¡Jefe herido! Vida restante: ", vida_jefe)
	
	# Efecto visual: Parpadeo en rojo rápido
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	
	# Comprobamos si el jefe murió
	if vida_jefe <= 0:
		print("¡JEFE DERROTADO!")
		morir()

func morir() -> void:
	# Aquí podrías sumar puntos, poner una animación de explosión o abrir una puerta
	# Por ahora, simplemente desaparece
	queue_free()

# --- Funciones de Disparo (Prueba) ---
func disparar_fuego() -> void:
	if escena_bola != null and player != null:
		# 1. Creamos un clon de la bola
		var nueva_bola = escena_bola.instantiate()
		
		# 2. Aparece exactamente donde está la cabeza (usamos global_position)
		nueva_bola.global_position = global_position
		
		# 3. Calculamos la dirección hacia el jugador y la normalizamos (flecha de puntería)
		var direccion_ataque = (player.global_position - global_position).normalized()
		nueva_bola.direccion = direccion_ataque
		
		# 4. La soltamos en el mundo (en tu sala)
		get_parent().add_child(nueva_bola)
	elif player == null:
		print("¡ERROR: Falta asignar el Player en el Inspector de la CabezaBoss!")

func _process(_delta: float) -> void:
	# MODO DE PRUEBA: Presiona la flecha ABAJO (o la S) para disparar
	if Input.is_action_just_pressed("ui_down"):
		print("¡Disparando bola de prueba dirigida!")
		disparar_fuego()
