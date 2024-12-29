extends CharacterBody3D

@onready var cam = $Camera3D
@onready var raycast = $Camera3D/RayCast3D
@onready var weapon = $Camera3D/Arm/Weapon

var max_health = 100
var health = max_health

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	if not is_multiplayer_authority(): return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	cam.current = true

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005)
		cam.rotate_x(-event.relative.y *0.005)
		cam.rotation.x = clamp(cam.rotation.x, -PI/2, PI/2)
	
	if Input.is_action_just_pressed('shoot'):
		if raycast.is_colliding():
			var hit_entity = raycast.get_collider()
			hit_entity.receive_damage.rpc_id(hit_entity.get_multiplayer_authority(), weapon.WEAPON_TYPE.damage)

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

@rpc("any_peer")
func receive_damage(damage):
	health -= damage
	print(health)
	if health <= 0:
		position = Vector3.ZERO
		health = max_health
