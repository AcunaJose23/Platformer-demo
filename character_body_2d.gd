extends CharacterBody2D

const walk_speed = 90.0
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

#contrareloj
@export var es_contrareloj: bool = false
@export var tiempo_maximo: float = 120.0

func _ready() -> void:
	aparecer = global_position
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	if es_contrareloj:
		time_elapsed = tiempo_maximo

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
		if jump_hold_time < 2.0:
			$Sprite2D.modulate = Color.WHITE
		elif jump_hold_time < 4.0:
			$Sprite2D.modulate = Color.YELLOW
		else:
			$Sprite2D.modulate = Color.RED
			
		# SALTAR PARA SOLTARSE 
		if Input.is_action_just_pressed("jump"):
			is_hanging = false
			
			if jump_hold_time < 2.0:
				velocity.y = JUMP_VELOCITY
			elif jump_hold_time < 4.0:
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
		$Sprite2D.modulate = Color.RED
	else:
		if jump_hold_time > 0.0:
			if jump_hold_time < 2.0:
				$Sprite2D.frame = 0
				$Sprite2D.modulate = Color.WHITE
			elif jump_hold_time < 4.0:
				$Sprite2D.frame = 1
				$Sprite2D.modulate = Color.YELLOW
			else:
				$Sprite2D.frame = 2
				$Sprite2D.modulate = Color.RED
		else:
			$Sprite2D.modulate = Color.WHITE

	# Execute jump buffer
	if jump_buffer_time > 0.0 and is_on_floor():
		if jump_hold_time < 2.0:
			velocity.y = JUMP_VELOCITY
		elif jump_hold_time < 4.0:
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
		#run input
		if Input.is_action_pressed("run") and running == false:
			speed = run_speed
			running = true
		elif Input.is_action_just_released("run") and running == true:
			speed = walk_speed
			running = false
			
		var direction := Input.get_axis("ui_left", "ui_right")
		
		if Input.is_action_pressed("look_up") or Input.is_action_pressed("look_down"):
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
			if friction == true:
				velocity.x = move_toward(velocity.x, 0, 7)
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
				
		if velocity.x == 0:
			running_time = 0.0
			friction = false
			
		if direction != 0:
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
		if velocity.y < 0:
			$Sprite2D.play("air_up") # Yendo hacia arriba
		else:
			$Sprite2D.play("air_up")
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
	
func lose_health() -> void:
	tiempo_daño = 0.2
	health -= 0.5
	if health <= 0:
		morir()
func morir() -> void:
	time_elapsed = 0
	Global.monedas = 0
	get_tree().call_deferred("reload_current_scene")
func reaparecer() -> void:
	global_position = aparecer
	velocity = Vector2.ZERO
