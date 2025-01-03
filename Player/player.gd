extends CharacterBody3D

@onready var neck = $Neck
@onready var head = $Neck/Head
@onready var cam = $Neck/Head/Camera3D
@onready var raycast = $Neck/RayCast3D
@onready var weapon = $Neck/Arm/Weapon
@onready var inventory = $Neck/Head/InteractionArea

#User Variables
var spawn_point : Vector3
var username : String

#Health Variables
const max_health = 100
var health = max_health

#Head Bobbing Variables
const head_bobbing_walking_speed = 14.0
const head_bobbing_walking_intensity = 0.1
const head_bobbing_sprinting_speed = 22.0
const head_bobbing_sprinting_intensity = 0.3

var head_bobbing_intensity = 0.0
var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0

#State Variables
var walking = false
var sprinting = false
var crouching = false

#Movement Variables
const walking_speed = 3
const sprinting_speed = 5
const crouching_speed = 1
var speed = 0.0
const JUMP_VELOCITY = 4.5

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	if not is_multiplayer_authority(): return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	cam.current = true

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	#Handle Camera Movement
	if event is InputEventMouseMotion and !inventory.inventory_open:
		rotate_y(-event.relative.x * 0.005)
		neck.rotate_x(-event.relative.y *0.005)
		neck.rotation.x = clamp(neck.rotation.x, -PI/2, PI/2)
	
	#Handle Sprint
	if Input.is_action_pressed("sprint"):
		walking = false
		sprinting = true
		speed = sprinting_speed
	else:
		sprinting = false
		walking = true
		speed = walking_speed
	
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
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = lerp(velocity.x, 0.0, 4 * delta)
		velocity.z = lerp(velocity.z, 0.0, 4 * delta)
	
	#Handle Head Bobbing
	if sprinting:
		head_bobbing_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed * delta
	elif walking:
		head_bobbing_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed * delta
	
	if is_on_floor() and direction:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2)+0.5
		
		head.position.y = lerp(head.position.y, head_bobbing_vector.y * (head_bobbing_intensity/2.0), delta)
		head.position.x = lerp(head.position.x, head_bobbing_vector.x * head_bobbing_intensity, delta)
	else:
		head.position.y = lerp(head.position.y, 0.0, delta * 3)
		head.position.x = lerp(head.position.x, 0.0, delta * 3)
	
	move_and_slide()

@rpc("any_peer")
func receive_damage(damage):
	health -= damage
	print(health)
	if health <= 0:
		position = spawn_point
		health = max_health
