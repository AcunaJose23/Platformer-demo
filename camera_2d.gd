extends Camera2D

@export var look_offset_y: float = 60.0 
@export var smooth_speed: float = 5.0 

var target_offset_y: float = 0.0

func _process(delta: float) -> void:
	if Input.is_action_pressed("look_up"):
		target_offset_y = -look_offset_y
	elif Input.is_action_pressed("look_down"):
		target_offset_y = look_offset_y
	else:
		target_offset_y = 0.0

	offset.y = lerp(offset.y, target_offset_y, smooth_speed * delta)
