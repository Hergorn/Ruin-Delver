extends Node2D

@export var id : int

@onready var pressed : bool
@onready var bodies : Array[Node2D]
@onready var previousState : bool
@onready var button : AnimatableBody2D = $buttonTop


func _ready() -> void:
	pressed = false
	previousState = false

func _process(delta: float) -> void:
	if previousState != pressed:
		var tween : Tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tween.set_parallel(false)
		match pressed:
			true: tween.tween_property(button, "position", Vector2(button.position.x , button.position.y + 6), 6)
			false: tween.tween_property(button, "position", Vector2(button.position.x , button.position.y - 6), 6)
		previousState = pressed

func _on_player_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("moveable"):
		bodies.append(body) 
		MechanismConnector.onlineMechanisms.append(id)
		pressed = true


func _on_player_area_body_exited(body: Node2D) -> void:
	if checkBody(body) == true: 
		var id = bodies.find(body,0)
		bodies.remove_at(0)
	if bodies == []:
		if MechanismConnector.checkStatus(id) == true: 
			MechanismConnector.deleteID(id)
			pressed = false

func checkBody(body : Node2D):
	for object in bodies:
		if body == object: return true
	return false
