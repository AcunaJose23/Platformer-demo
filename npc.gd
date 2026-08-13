extends CharacterBody2D

var player_near = false
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_near = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_near = false

func _process(delta: float) -> void:
	if player_near and Input.is_action_just_pressed("talk"):
		DialogueManager.show_dialogue_balloon(load("res://Try.dialogue"), "start")
	
