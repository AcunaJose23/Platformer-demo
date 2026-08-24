extends CharacterBody2D

const walk_speed = 80.0
const run_speed = 160.0
var speed = walk_speed
const JUMP_VELOCITY = -300.0
var jump_hold_time = 0.0
var dialogue_active = false
var idle_time = 0.0
var running = false
var running_time = 0.0
var friction = false
var time_elapsed: float = 0.0

#vars rama
var is_hanging = false
var active_branch : Node2D = null

#jump buffering
var jump_buffer_time: float = 0.0
const JUMP_BUFFER_TIME = 0.1

#vida
var health = 3
var tiempo_daño = 0.0

#aparecer
var aparecer: Vector2

#parry
var haciendo_parry = false

#contrareloj
@export var es_contrareloj: bool = false
@export var tiempo_maximo: float = 120.0

@export var boss: bool = false
@export var limite_izq_camara: int = 0
@export var limite_der_camara: int = 331

func _ready() -> void:
	aparecer = global_position
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	if es_contrareloj:
		time_elapsed = tiempo_maximo
	
	if boss == true:
		# Le decimos a la cámara que no pase de estos píxeles
		$Camera2D.limit_left = limite_izq_camara
		$Camera2D.limit_right = limite_der_camara
	# --- NUEVO: Limpiar el Shader al nacer ---
	if $Sprite2D.material != null:
		$Sprite2D.material.set_shader_parameter("charge_color", Color.WHITE)
		$Sprite2D.material.set_shader_parameter("flash_amount", 0.0)

func _on_dialogue_started(_resource) -> void:
	dialogue_active = true
	velocity = Vector2.ZERO

func _on_dialogue_ended(_resource) -> void:
	dialogue_active = false

#funciones rama
func set_active_branch(branch: Node2D):
	active_branch = branch

func remove_active_branch(branch: Node2D):
	if active_branch == branch:
		active_branch = null

func _physics_process(delta: float) -> void:
	if dialogue_active:
		velocity = Vector2.ZERO
		return	
		
	if Global.espada:
	# Añadimos 'and not haciendo_parry' para que no puedas spamear el botón
		if Input.is_action_just_pressed("Parry") and not haciendo_parry:
			haciendo_parry = true
		
			# ¡Reproducimos la animación! (Asegúrate de que el nombre coincida exacto)
			$Sprite2D.play("parry") 
			$HitboxEspada/CollisionShape2D.disabled = false 
			# El tiempo activo del parry (Ajusta esto a lo que dure tu animación, ej: 0.3)
			await get_tree().create_timer(0.3).timeout 
			$HitboxEspada/CollisionShape2D.disabled = true 
			haciendo_parry = false # Quitamos el cartel de "No molestar"

	# 1. Agarrarse a la rama
	if active_branch != null and Input.is_action_just_pressed("grab") and not is_hanging:
		is_hanging = true
		global_position = active_branch.global_position
		velocity = Vector2.ZERO
		jump_hold_time = 0.0 

	# 2. Comportamiento mientras está colgado
	if is_hanging:
		velocity = Vector2.ZERO 
		
		# Cargar salto mientras estás en la rama
		if Input.is_action_pressed("charge_jump"):
			jump_hold_time += delta
		
		# Cambiar color según el tiempo
		if jump_hold_time < 1.0:
			$Sprite2D.modulate = Color.WHITE
		elif jump_hold_time < 2.5:
			$Sprite2D.modulate = Color.YELLOW
		else:
			$Sprite2D.modulate = Color.RED
			
		# SALTAR PARA SOLTARSE 
		if Input.is_action_just_pressed("jump"):
			is_hanging = false
			
			if jump_hold_time < 1.0:
				velocity.y = JUMP_VELOCITY
			elif jump_hold_time < 2.5:
				velocity.y = JUMP_VELOCITY * 1.3
			else:
				velocity.y = JUMP_VELOCITY * 1.5
				
			jump_hold_time = 0.0
			$Sprite2D.modulate = Color.WHITE
			
		# Soltarse al soltar el botón rápido (o cancelar carga)
		if Input.is_action_just_released("charge_jump"):
			if jump_hold_time <= 0.2:
				is_hanging = false
			jump_hold_time = 0.0
			$Sprite2D.modulate = Color.WHITE
			
		move_and_slide()
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	#buffer time
	if jump_buffer_time > 0.0:
		jump_buffer_time -= delta
	if Input.is_action_just_pressed("jump"):
		jump_buffer_time = JUMP_BUFFER_TIME

	# Handle jump charge on floor.
	if Input.is_action_pressed("charge_jump") and is_on_floor():
		jump_hold_time += delta
		$Sprite2D.animation = "Jump"
		$Sprite2D.stop()
	if Input.is_action_just_released("charge_jump"):
		jump_hold_time = 0.0
	
	# Cambiar color según el tiempo
	if tiempo_daño > 0.0:
		tiempo_daño -= delta
	else:
		if jump_hold_time > 0.0:
			if jump_hold_time < 1.0:
				$Sprite2D.frame = 0
				$Sprite2D.material.set_shader_parameter("charge_color", Color.WHITE)
			elif jump_hold_time < 2.5:
				$Sprite2D.frame = 1
				$Sprite2D.material.set_shader_parameter("charge_color", Color.YELLOW)
			else:
				$Sprite2D.frame = 2
				$Sprite2D.material.set_shader_parameter("charge_color", Color.RED)
		else:
			$Sprite2D.material.set_shader_parameter("charge_color", Color.WHITE)

	# Execute jump buffer
	if jump_buffer_time > 0.0 and is_on_floor():
		if jump_hold_time < 1.0:
			velocity.y = JUMP_VELOCITY
		elif jump_hold_time < 2.5:
			velocity.y = JUMP_VELOCITY * 1.3
		else:
			velocity.y = JUMP_VELOCITY * 1.5
		jump_buffer_time = 0.0
		jump_hold_time = 0.0
		$Sprite2D.modulate = Color.WHITE
		
	# Orientación mientras se carga en el suelo
	if jump_hold_time > 0.0:
		velocity.x = 0.0
		if Input.is_action_pressed("ui_right"):
			$Sprite2D.flip_h = false
		if Input.is_action_pressed("ui_left"):
			$Sprite2D.flip_h = true
	else:
		#run input and inertia
		if Input.is_action_pressed("run"):
			speed = run_speed * 0.8
			running = true
			#Inertia
			if running_time >= 1.5:
				speed = run_speed * 1
			if running_time >= 2.5:
				speed = run_speed * 1.3
		elif Input.is_action_just_released("run") and running == true:
			speed = walk_speed
			running = false
			
		var direction := Input.get_axis("ui_left", "ui_right")
		
		if Input.is_action_pressed("look_up") or Input.is_action_pressed("look_down"):
			direction = 0
		if tiempo_daño > 0.0:
			direction = 0
		if direction and running == true:
			velocity.x = direction * speed
			running_time += delta
			if running_time > 1.5:
				friction = true
		elif direction:
			velocity.x = direction * speed
			running_time = 0.0
			friction = false
		else:
			if tiempo_daño > 0.0:
				velocity.x = move_toward(velocity.x, 0, 5)
			elif friction == true:
				velocity.x = move_toward(velocity.x, 0, 7)
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
				
		if velocity.x == 0:
			running_time = 0.0
			friction = false
			
		if direction != 0:
			if tiempo_daño <= 0.0 and not haciendo_parry:
				if running:
					$Sprite2D.play("Run")
				else:
					$Sprite2D.play("default")
				if direction > 0:
					$Sprite2D.flip_h = false
				if direction < 0:
					$Sprite2D.flip_h = true
				
	# Idle animation
	if is_on_floor() and velocity.x == 0 and not is_hanging and jump_hold_time == 0:
		idle_time += delta
		if tiempo_daño <= 0.0 and not haciendo_parry:
			$Sprite2D.play("idle")
			if idle_time >= 3.0:
				$Sprite2D.play("idle")
	else:
		idle_time = 0.0

	if not is_on_floor() and not is_hanging:
		
		# 1. ORIENTACIÓN (Izquierda o Derecha)
		if velocity.x > 0:
			$Sprite2D.flip_h = false # Mirar a la derecha
		elif velocity.x < 0:
			$Sprite2D.flip_h = true  # Mirar a la izquierda
			
		# 2. ANIMACIÓN (Subiendo o Cayendo)
		if tiempo_daño <= 0.0 and not haciendo_parry:
			if velocity.y < 0:
				$Sprite2D.play("air_up") # Yendo hacia arriba
			else:
				$Sprite2D.play("air_down")
	move_and_slide()
	
func _process(delta: float) -> void:
	if es_contrareloj:
		time_elapsed -= delta
		if time_elapsed <= 0:
			time_elapsed = 0
			morir()
	else:
		time_elapsed += delta
	
	# --- OPCIÓN 1: Solo segundos (Ej: "Tiempo: 15") ---
	# Usamos int() para borrar los decimales
	$CanvasLayer/Time.text = "Time: " + str(int(time_elapsed))
	$CanvasLayer/Coins.text = "Coins: " + str(int(Global.monedas))
	
	#No se, ver vidas (La vara omg)
	$CanvasLayer/Health/Heart.visible = health >= 0.5
	$CanvasLayer/Health/Heart2.visible = health >= 1.5
	$CanvasLayer/Health/Heart3.visible = health >= 2.5
	
func lose_health(enemigo_pos_x: float = 0.0) -> void:
	if tiempo_daño > 0.0:
		return
	Hit_flash()
	tiempo_daño = 0.8
	health -= 0.5
	$Sprite2D.play("dmg")
	jump_hold_time = 0.0
	
	var direccion_empuje = 1
	if enemigo_pos_x != 0.0:
		if global_position.x < enemigo_pos_x:
			direccion_empuje = -1
		else:
			direccion_empuje = 1
	velocity.y = -200
	velocity.x = direccion_empuje * 200
	if health <= 0:
		morir()

func caer_vacio() -> void:
	health -= 1.0 # Quitamos 1 de vida entero (el equivalente a dos golpes de 0.5)
	# Aquí no hay knockback ni tiempo de inmunidad, solo evaluamos si muere o reaparece
	if health <= 0:
		morir()
	else:
		reaparecer()


func morir() -> void:
	time_elapsed = 0
	Global.monedas = 0
	get_tree().call_deferred("reload_current_scene")
func reaparecer() -> void:
	global_position = aparecer
	velocity = Vector2.ZERO

#Hit Flash
func Hit_flash() -> void:
	# Verificamos que el Sprite tenga el Material asignado para evitar errores
	if $Sprite2D.material != null:
		# Ponemos el destello al máximo (blanco total)
		$Sprite2D.material.set_shader_parameter("flash_amount", 1.0)
		
		# Creamos una animación (Tween) para devolverlo a 0.0 en 0.2 segundos
		var tween = create_tween()
		tween.tween_property($Sprite2D.material, "shader_parameter/flash_amount", 0.0, 0.2)


func _on_hitbox_espada_area_entered(area: Area2D) -> void:
	# Si la espada choca con algo que esté en el grupo "bola_fuego"...
	if area.is_in_group("bola_fuego") and area.has_method("ser_parreada"):
		area.ser_parreada() # ¡Le hacemos el parry!
