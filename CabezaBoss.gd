extends Area2D

# --- Variables de Movimiento ---
var pos_abajo = Vector2(213, 300) 
var pos_arriba = Vector2(213, 125) 

# --- Referencias ---
@export var escena_bola: PackedScene
@export var player: Node2D 
@export var cola_boss: Node2D 

var vida_jefe = 3

# --- Control de Animaciones ---
var esta_recibiendo_dano = false
var esta_atacando = false

func _ready() -> void:
	position = pos_abajo
	
	# Conectar animaciones y poner estado base
	$Sprite2D.play("default")
	$Sprite2D.animation_finished.connect(_on_animation_finished)
	
	await get_tree().create_timer(0.5).timeout 
	aparecer()

# --- Funciones de Movimiento e Inteligencia ---
func aparecer() -> void:
	# Ponemos la animación "up" si no le están pegando
	if not esta_recibiendo_dano:
		$Sprite2D.play("up")
		
	var tween = create_tween()
	tween.tween_property(self, "position", pos_arriba, 1.5).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(_al_terminar_de_subir)

func _al_terminar_de_subir() -> void:
	# LIMPIEZA DE CEREBRO: Pase lo que pase, al llegar arriba se resetea
	esta_atacando = false
	esta_recibiendo_dano = false
	
	# Obligamos a que vuelva a su pose relajada
	$Sprite2D.play("default")
		
	pensar_ataque()

func esconder() -> void:
	# Usamos la misma animación "up" para bajar
	if not esta_recibiendo_dano:
		$Sprite2D.play("up")
		
	var tween = create_tween()
	tween.tween_property(self, "position", pos_abajo, 1.0).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(_al_terminar_de_bajar)

func _al_terminar_de_bajar() -> void:
	if not esta_recibiendo_dano and not esta_atacando:
		$Sprite2D.play("default")

# --- EL CEREBRO DE LA IA ---
func pensar_ataque() -> void:
	if vida_jefe <= 0:
		return 
		
	# Le damos 1.5 segundos al jugador para que respire entre ataques
	await get_tree().create_timer(1.5).timeout
	
	# Si justo en este momento le están pegando, le damos un chance y volvemos a pensar
	if esta_recibiendo_dano:
		pensar_ataque()
		return
	
	# Tirar una moneda al azar (1 o 2)
	var eleccion = randi_range(1, 2)
	
	if eleccion == 1:
		# ATAQUE DE FUEGO
		disparar_fuego()
	else:
		# ATAQUE DE COLA
		if cola_boss != null:
			cola_boss.ataque_barrido()

# --- Funciones de Daño ---
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bola_fuego") and area.fue_parreada:
		recibir_dano()
		area.queue_free() 

func recibir_dano() -> void:
	vida_jefe -= 1
	print("¡Jefe herido! Vida restante: ", vida_jefe)
	
	# EL ARREGLO: Cancelamos cualquier ataque a la fuerza al recibir el golpe
	esta_atacando = false
	
	# Activamos estado de daño
	esta_recibiendo_dano = true
	$Sprite2D.play("damaged")
	
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	
	if vida_jefe <= 0:
		print("¡JEFE DERROTADO!")
		morir()

func morir() -> void:
	queue_free()
	Global.nivel_destino = "res://MenuPrincipal.tscn"
	Transicion.cambiar_escena("res://pantalla_puntuacion.tscn")
	Global.espada = false

# --- Funciones de Disparo ---
func disparar_fuego() -> void:
	# Si le están pegando, cancelamos el ataque y lo intentamos de nuevo más tarde
	if esta_recibiendo_dano: 
		pensar_ataque()
		return 
		
	esta_atacando = true
	$Sprite2D.play("charge") # Empieza a cargar
	
	# Esperamos 1 segundo de carga (ajusta este tiempo a lo que dure tu animación)
	await get_tree().create_timer(1.0).timeout
	
	# Si le pegaron un espadazo justo mientras cargaba, le cancelamos el ataque
	if esta_recibiendo_dano: 
		pensar_ataque()
		return
		
	$Sprite2D.play("shoot") # Tira la bola
	
	if escena_bola != null and player != null:
		var nueva_bola = escena_bola.instantiate()
		nueva_bola.global_position = global_position
		var direccion_ataque = (player.global_position - global_position).normalized()
		nueva_bola.direccion = direccion_ataque
		get_parent().add_child(nueva_bola)
		
	# Como ya terminó todo su show de atacar, reiniciamos el cerebro para el siguiente ataque
	pensar_ataque()

# --- Controlador que devuelve el Jefe a la normalidad ---
func _on_animation_finished() -> void:
	if $Sprite2D.animation == "damaged":
		esta_recibiendo_dano = false
		if not esta_atacando:
			$Sprite2D.play("default")
			
	elif $Sprite2D.animation == "shoot":
		esta_atacando = false
		$Sprite2D.play("default")
