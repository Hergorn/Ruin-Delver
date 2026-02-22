extends Area2D

@export var id : int

func _ready(): add_to_group("mechanism")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("moveable"): 
		MechanismConnector.onlineMechanisms.append(id)

func _on_body_exited(body: Node2D) -> void: 
	if MechanismConnector.checkStatus(id) == true: MechanismConnector.deleteID(id)
