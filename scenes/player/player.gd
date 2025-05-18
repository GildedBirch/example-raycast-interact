class_name Player
extends CharacterBody3D


## Speed of player movement
var speed: float = 5.0
## Used to smooth player movement
const lerp_speed: float = 10.0
## Direction of player movement, so we can smooth it
var direction: Vector3 = Vector3.ZERO
## Mask of the interaction ray
@export_flags_3d_physics var ray_mask: int


func _input(event: InputEvent) -> void:
	# Handling player inputs
	# Closing the game
	if event.is_action_pressed(&"debug_quit"):
		get_tree().quit()
	# Interacting
	if event.is_action_pressed(&"interact"):
		_interact()


func _physics_process(delta: float) -> void:
	# Moving the player around
	# Input direction
	var input_dir: Vector2 = Input.get_vector(&"strafe_left", &"strafe_right", &"move_forward", &"move_backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized(), lerp_speed * delta)
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()


# Interact in it's own fuction to make things cleaner
func _interact() -> void:
	# Get position of the mouse on screen
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	# Shoot raycast from mouse position to 5 meters forward
	var hit: Dictionary = screen_to_world_ray(mouse_pos, ray_mask, 5.0,  false)
	# if raycast didn't hit anything return
	if not hit:
		return
	# Get collider from raycasts dictionary
	var collider: Area3D = hit["collider"]
	# Print out what we hit and where for debug
	print("Node %s got hit at position %s" % [collider.name, hit["position"]])
	# If the Area wasn't TargetArea3D return
	if not collider is TargetArea3D:
		return
	# Final check if there is actually node and if it has interact_target boolean on
	if collider and collider.interact_target:
		# Run interact function on the object raycast hit
		collider.interact()

## screen_position:
## This is the position on screen the raycast will be shot from
## Most often this is mouse position. Get it with:
## get_viewport().get_mouse_position()
##
## mask:
## mask is the collision layers raycast will hit
## Read more here: https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html#code-example
## Easiest way to create a mask would be export flags:
## @export_flags_3d_physics var mask: int
##
## length:
## Length of the ray
##
## collide_with_bodies and collide_with_areas:
## decides if the ray will hit bodies and/or areas
## If you don't want to hit random walls toggle off collide_with_bodies
##
## Returns a Dictionary with information of first object that was hit (if any)
## {"position", "normal", "face_index", "collider_id", "collider", "shape", "rid"}
## Most important from there are of course:
## "position" is the point where ray hit the object
## "collider" is the object that got hit
func screen_to_world_ray(screen_position: Vector2, mask: int, length: float = 2000, collide_with_bodies: bool = true, collide_with_areas: bool = true) -> Dictionary:
	# Don't ask me what this actually means. We just need to know how 3D space is so we can work in it.
	var space_state = get_world_3d().direct_space_state
	# Getting the currently active camera
	var camera: Camera3D = get_tree().root.get_camera_3d()
	# Point from where the ray will be shot from
	var ray_origin: Vector3 = camera.project_ray_origin(screen_position)
	# Point where the ray will end
	var ray_end: Vector3 = ray_origin + camera.project_ray_normal(screen_position) * length
	# Constructing the actual ray
	var ray = PhysicsRayQueryParameters3D.create(ray_origin, ray_end, mask)
	# Setting body and area collisions
	ray.collide_with_areas = collide_with_areas
	ray.collide_with_bodies = collide_with_bodies
	# Shooting the ray and returning Dictionary if hit anything
	return space_state.intersect_ray(ray)
