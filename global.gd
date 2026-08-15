extends Node

# Esta es la función universal para cambiar de nivel
func cambiar_nivel(ruta_escena: String) -> void:
	get_tree().change_scene_to_file(ruta_escena)
