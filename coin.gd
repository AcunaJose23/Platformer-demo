extends Area2D
func _ready() -> void:
	$AnimatedSprite2D.play("coin")
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		Global.monedas += 10 # Suma a script global
		queue_free() # Hace que la moneda desaparezca
	
