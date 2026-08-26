extends Area2D

# --- Variables de Movimiento ---
var pos_abajo = Vector2(213, 257) 
var pos_arriba = Vector2(213, 43) 

# --- Referencias ---
@export var escena_bola: PackedScene
@export var player: Node2D 
@export var cola_boss: Node2D # <--- NUEVO: El jefe necesita saber dónde está su cola

var vida_jefe = 3

func _ready() -> void:
	position = pos_abajo
	await get_tree().create_timer(0.5).timeout 
	aparecer()

# --- Funciones de Movimiento e Inteligencia ---
func aparecer() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", pos_arriba, 1.5).set_trans(Tween.TRANS_SINE)
	
	# NUEVO: Cuando termine de subir, conectamos el final de la animación a su "Cerebro"
	tween.finished.connect(pensar_ataque)

func esconder() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", pos_abajo, 1.0).set_trans(Tween.TRANS_SINE)

# --- EL CEREBRO DE LA IA ---
func pensar_ataque() -> void:
	if vida_jefe <= 0:
		return # Si está muerto, que no haga nada
		
	# 1. Le damos 1.5 segundos al jugador para que respire entre ataques
	await get_tree().create_timer(1.5).timeout
	
	# 2. Tirar una moneda al azar (1 o 2)
	var eleccion = randi_range(1, 2)
	
	if eleccion == 1:
		# ATAQUE DE FUEGO
		disparar_fuego()
		# Como el fuego es rápido, reiniciamos el cerebro nosotros mismos
		pensar_ataque() 
	else:
		# ATAQUE DE COLA
		if cola_boss != null:
			cola_boss.ataque_barrido()
			# ¡No reiniciamos el cerebro aquí! Porque la cola se encargará de 
			# volver a llamar a aparecer() cuando termine su ataque.

# --- Funciones de Daño ---
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bola_fuego") and area.fue_parreada:
		recibir_dano()
		area.queue_free() 

func recibir_dano() -> void:
	vida_jefe -= 1
	print("¡Jefe herido! Vida restante: ", vida_jefe)
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	
	if vida_jefe <= 0:
		print("¡JEFE DERROTADO!")
		morir()

func morir() -> void:
	queue_free()

# --- Funciones de Disparo ---
func disparar_fuego() -> void:
	if escena_bola != null and player != null:
		var nueva_bola = escena_bola.instantiate()
		nueva_bola.global_position = global_position
		var direccion_ataque = (player.global_position - global_position).normalized()
		nueva_bola.direccion = direccion_ataque
		get_parent().add_child(nueva_bola)
