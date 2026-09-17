extends CharacterBody3D

# game feel

@export_group("Movimiento")
# velocidad máxima a la que camina el player 
@export var SPEED: float = 8.0

# aceleración, qué tan rápido alcanza la velocidad máxima
@export var ACCEL: float = 16.0

# desaceleración, qué tan rápido se detiene al soltar las teclas
@export var DECEL: float = 24.0

@export_group("jump")
# fuerza del salto, que tan alto saltra
@export var JUMP_VELOCITY: float = 7.0

# cantidad máxima de saltos antes de tocar el suelo (2, doble salto)
@export var MAX_JUMPS: int = 2

@export_group("Camera3D")
# sensibilidad para rotar la cámara 
@export var MOUSE_SENSITIVITY: float = 0.003

# Variables internas
# me da el valor de la gravedad configurado por default en godot
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# count interno de cuántos saltos le quedan al player
var jumps_left: int = 2

# referencia al nodo de la cámara que está dentro del player
@onready var camera: Camera3D = $Camera3D

func _ready() -> void:
	# hide mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# func q detecta eventos de entrada (el mov del mouse)
func _input(event: InputEvent) -> void:
	# verifica si el player movio el mopuse
	if event is InputEventMouseMotion:
		# en lugar de girar todo el personaje, giramos el eje horizontal de la camara
		camera.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)

		# mueve la cámara de arriba a abajo (eje X)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)

		# limita la rotación vertical de la camara para que no gire en 360°
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		camera.rotation.z = 0.0

func _physics_process(delta: float) -> void:
	
	# aplica gravedad
	# Si el personaje no está tocando el piso, aplica gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		# if it touches the ground, it resets the jump counter
		jumps_left = MAX_JUMPS

	# salto y doble salto
	# se  apreta espacio COPRREGIRT EN INPUTS 
	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		# velocidad EJE Y
		velocity.y = JUMP_VELOCITY
		# resta un salto disponible
		jumps_left -= 1

# movimiento de player wasd
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# convierte la dirección 2D del teclado a una dirección en el espacio 3D
	# tomando en cuenta hacia dónde está mirando el player (transform.basis)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction.y = 0 # Mantiene el movimiento estrictamente en el plano horizontal
	direction = direction.normalized()
	
# aceleración y movimiento
	if direction != Vector3.ZERO:
		# si apreta w a s o d, aceleramos hacia esa dirección
		velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCEL * delta)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, ACCEL * delta)

		# Gira la mesh de los a la dirección donde camino
		var target_angle := atan2(-direction.x, -direction.z)
		$MeshInstance3D.rotation.y = lerp_angle($MeshInstance3D.rotation.y, target_angle - rotation.y, 12.0 * delta)
	else:
		# si no hay teclas presionadas, frena de a poco hasta llegar a 0
		velocity.x = move_toward(velocity.x, 0, DECEL * delta)
		velocity.z = move_toward(velocity.z, 0, DECEL * delta)

	move_and_slide()
