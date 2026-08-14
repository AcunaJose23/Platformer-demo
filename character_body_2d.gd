extends CharacterBody2D


const walk_speed = 90.0
const run_speed = 160.0
var speed = walk_speed
const JUMP_VELOCITY = -300.0
var jump_hold_time = 0.0
var dialogue_active = false
var running = false
var running_time = 0.0
var friction = false

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _on_dialogue_started(_resource) -> void:
	dialogue_active = true
	velocity = Vector2.ZERO


func _on_dialogue_ended(_resource) -> void:
	dialogue_active = false
	#cant move while on dialogue
func _physics_process(delta: float) -> void:
	if dialogue_active:
		velocity = Vector2.ZERO
		return	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_pressed("ui_down") and is_on_floor():
		jump_hold_time += delta
	if Input.is_action_just_released("ui_down"):
		jump_hold_time = 0.0
	
		# Cambiar color según el tiempo
	if jump_hold_time < 2.0:
		$Sprite2D.modulate = Color.WHITE
	elif jump_hold_time < 4.0:
		$Sprite2D.modulate = Color.YELLOW
	else:
		$Sprite2D.modulate = Color.RED

	if Input.is_action_just_pressed("jump") and is_on_floor():
		if jump_hold_time < 2.0:
			velocity.y = JUMP_VELOCITY
		elif jump_hold_time < 4.0:
			velocity.y = JUMP_VELOCITY * 1.3
		else:
			velocity.y = JUMP_VELOCITY * 1.5
		jump_hold_time = 0.0
		$Sprite2D.modulate = Color.WHITE
	if jump_hold_time > 0.0:
		velocity.x = 0.0
		if Input.is_action_just_pressed("ui_right"):
			$Sprite2D.flip_h = false
		if Input.is_action_just_pressed("ui_left"):
			$Sprite2D.flip_h = true
	else:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#run input
		if Input.is_action_just_pressed("run") and running == false:
			speed = run_speed
			running = true
		elif Input.is_action_just_pressed("run") and running == true:
			speed = walk_speed
			running = false
		var direction := Input.get_axis("ui_left", "ui_right")
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
			$Sprite2D.play("default")
			if direction > 0:
				$Sprite2D.flip_h = false
			if direction < 0:
				$Sprite2D.flip_h = true
		

	move_and_slide()
