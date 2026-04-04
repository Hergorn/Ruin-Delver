extends RigidBody2D

@export var rotationOverride: bool
@export var massOverride : float


func _ready() -> void:
	add_to_group("moveable")
