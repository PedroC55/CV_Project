extends CharacterBody3D

# Variables
var grabbed_object: RigidBody3D = null
@onready var detection_area = $Head/Area3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.01
const GRAB_OFFSET = Vector3(2, 1, 0)

@onready var head = $Head
@onready var camera = $Head/Camera3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	detection_area.body_entered.connect(self._on_body_entered)
	detection_area.body_exited.connect(self._on_body_exited)

# List of objects in the detection area
var objects_in_area = []

func _on_body_entered(body):
	if body is RigidBody3D:
		objects_in_area.append(body)

func _on_body_exited(body):
	if body is RigidBody3D:
		objects_in_area.erase(body)


func _process(delta):
	if Input.is_action_just_pressed("grab"):
		if grabbed_object:
			release_object()
		else:
			try_grab_object()
	if grabbed_object:
		update_grabbed_object_position()

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

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

func try_grab_object():
	if objects_in_area.size() > 0:
		grabbed_object = objects_in_area[0]  # Grab the first object in the area
		grabbed_object.freeze = true
		print("Object grabbed:", grabbed_object.name)

func release_object():
	if grabbed_object:
		grabbed_object.freeze = false
		grabbed_object = null
		print("Object released")
		
# Function to update the position of the grabbed object
func update_grabbed_object_position():
	if grabbed_object:
		# Set the position of the grabbed object relative to the player (camera/head)
		grabbed_object.get_parent_node_3d().position = head.position + head.transform.basis.x * GRAB_OFFSET.x + GRAB_OFFSET
		print(grabbed_object.get_parent_node_3d().position)
		# Optionally, you may want to keep the object oriented in a certain way. If so, set the rotation too:
		# grabbed_object.rotation = camera.rotation
