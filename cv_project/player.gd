extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.01

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var interaction = $Head/Camera3D/interaction
@onready var hand = $Head/Camera3D/hand
@onready var joint = $Head/Camera3D/Generic6DOFJoint3D
@onready var staticbody = $Head/Camera3D/StaticBody3D

var picked_object
var pull_power = 4
var rotation_power = 0.05
var locked = false

var camera_pitch = 0.0 # Track camera's vertical rotation (pitch)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	if Input.is_action_pressed("grab"):
		if picked_object == null:
			pick_object()
		elif picked_object != null:
			remove_object()

func pick_object():
	var collider = interaction.get_collider()
	if collider != null and collider is RigidBody3D:
		picked_object = collider
		joint.set_node_b(picked_object.get_path())
		
func remove_object():
	if picked_object != null:
		picked_object = null
		joint.set_node_b(joint.get_path())

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		# Rotate the head (yaw) based on horizontal mouse motion
		head.rotate_y(-event.relative.x * SENSITIVITY)

		# Adjust the camera pitch based on vertical mouse motion
		camera_pitch = clamp(camera_pitch - event.relative.y * SENSITIVITY, deg_to_rad(-40), deg_to_rad(60))
		camera.rotation.x = camera_pitch

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	if picked_object != null:
		var a = picked_object.global_transform.origin
		var b = hand.global_transform.origin
		picked_object.set_linear_velocity((b-a) * pull_power)
