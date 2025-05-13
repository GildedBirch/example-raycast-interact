class_name Door
extends TargetArea3D

## Door extends base class TargetArea3D
## which has boolean for checking if it's interact target.


## enum for door state
enum DoorState {CLOSED, OPEN}
## state of the door. Open or closed
var door_state: DoorState = DoorState.CLOSED
## Reference to door hinge so we can rotate it
@onready var door_hinge: Node3D = %DoorHinge


## interact function overwritten from the base class
## Put anything here, I just have some tween magic to open and close door
func interact() -> void:
	match door_state:
		DoorState.CLOSED:
			var tween: Tween = get_tree().create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(door_hinge, "rotation_degrees:y", 90.0, 1.0)
			door_state = DoorState.OPEN
		DoorState.OPEN:
			var tween: Tween = get_tree().create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(door_hinge, "rotation_degrees:y", 0.0, 1.0)
			door_state = DoorState.CLOSED
