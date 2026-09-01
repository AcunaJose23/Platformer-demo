extends TextureRect # O Sprite2D, CharacterBody2D, Control, etc.

var tiempo: float = 0.0
@export var amplitud: float = 10.0 # Cuántos píxeles se moverá hacia los lados
@export var velocidad: float = 2.0 # Qué tan rápido se mueve

var posicion_inicial_x: float

func _ready():
	# Guardamos su posición original para que flote alrededor de ella
	posicion_inicial_x = position.x

func _process(delta):
	tiempo += delta
	# La magia matemática: sin() crea una onda perfecta y suave
	position.x = posicion_inicial_x + (sin(tiempo * velocidad) * amplitud)
