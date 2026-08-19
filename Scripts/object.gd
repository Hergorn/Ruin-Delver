extends RigidBody2D

@export var rotationOverride: bool
@export var massOverride : float
@export_enum("wood") var objectMaterial : String
@export_enum("box") var objectType : String


func _ready() -> void:
	add_to_group("moveable")

func _physics_process(delta: float) -> void:
	print(get_colliding_bodies())
