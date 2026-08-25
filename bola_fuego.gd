extends Area2D

var velocidad = 250
var direccion = Vector2.DOWN # Empieza hacia abajo, pero la Cabeza lo cambiará
var fue_parreada = false

func _process(delta: float) -> void:
	position += direccion * velocidad * delta
	rotation = direccion.angle() - (PI / 2)

func _on_body_entered(body: Node2D) -> void:
	if not fue_parreada and body.has_method("lose_health"):
		body.lose_health(global_position.x)
		queue_free()
		
func ser_parreada() -> void:
	fue_parreada = true
	
	# --- NUEVO: Efecto Boomerang ---
	# Al multiplicar la dirección por -1, se devuelve exactamente a su origen
	direccion = direccion * -1 
	
	velocidad = 400
	$Sprite2D.modulate = Color.CYAN
