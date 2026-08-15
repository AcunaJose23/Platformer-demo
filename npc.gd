extends CharacterBody2D

var player_near = false
var player_node = null
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
			Global.calcular_puntaje(player_node.time_elapsed)
			DialogueManager.show_dialogue_balloon(load("res://Try.dialogue"), "start")
	
