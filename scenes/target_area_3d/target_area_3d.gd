class_name TargetArea3D
extends Area3D

## Any Nodes that can be interacted with should be extened from this base class

## Marks area as someting that can be targeted
@export var interact_target: bool


## This interact function should be overwritten by classes that inherit this base class
func interact() -> void:
	push_warning("Interact not implemented in %s" % name)
