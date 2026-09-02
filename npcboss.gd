extends CharacterBody2D

var player_near = false
var player_node = null

# --- NUEVO 1: Variable para saber si ESTE npc es el que habla ---
var is_talking = false 

# --- NUEVO 2: Función _ready para conectar la señal al nacer ---
func _ready() -> void:
	$AnimatedSprite2D.play("default") # Que empiece normal
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_near = true
		player_node = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_near = false
		player_node = null

func _process(_delta: float) -> void:
	if player_near and Input.is_action_just_pressed("talk"):
		if not player_node.dialogue_active:
			
			# --- NUEVO 3: Activamos la animación justo antes del texto ---
			is_talking = true
			$AnimatedSprite2D.play("talk")
			
			Global.calcular_puntaje(player_node.time_elapsed)
			DialogueManager.show_dialogue_balloon(load("res://dIALOGO 2.dialogue"), "start")
			
# --- NUEVO 4: Función que se dispara cuando el globo se cierra ---
func _on_dialogue_ended(_resource) -> void:
	if is_talking: # Si yo era el que estaba hablando...
		is_talking = false
		$Sprite2D.play("default") # Me callo y vuelvo a la normalidad
