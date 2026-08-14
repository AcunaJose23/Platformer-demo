extends Area2D



func _on_body_entered(body: Node2D) -> void:
	# Si el objeto que entró tiene la función "set_active_branch" (tu jugador), le pasamos esta rama
	if body.has_method("set_active_branch"):
		body.set_active_branch(self)


func _on_body_exited(body: Node2D) -> void:
	# Si sale del área, le quitamos la referencia
	if body.has_method("remove_active_branch"):
		body.remove_active_branch(self)
