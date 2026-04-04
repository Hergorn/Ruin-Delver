extends Node2D

@export_enum("left", "right") var direction : String
@export var needsSwitch : bool
@export var isOn : bool
@export var length : int #unter 2 wird automatisch auf 2 gesetzt
@export var id : int
@export var speed : float

@onready var leftPart : StaticBody2D = $hidden/leftPart
@onready var middlePart : StaticBody2D = $hidden/middlePart
@onready var rightPart : StaticBody2D = $hidden/rightPart
@onready var conveyorBody : Node2D = $body
@onready var hide : Node2D = $hidden
@onready var shapeCollision : CollisionShape2D

var conveyorParts : Array[StaticBody2D]
var lastState : bool

func _ready() -> void:
	#Debug
	add_to_group("conveyor")
	#Aufbau
	if length < 2: length = 2
	#AREA
	for i in length:
		var currentPart : int = length - i
		var newPart : StaticBody2D
		match currentPart:
			length: 
				newPart =  leftPart.duplicate()
				for child in newPart.get_children():
					if child.name == "conveyorCollision": shapeCollision = child
			1: newPart =  rightPart.duplicate()
			_: newPart =  middlePart.duplicate()
		newPart.position.x = i * 48
		conveyorBody.add_child(newPart)
		conveyorParts.append(newPart)
	shapeCollision.visible = false
	#Einschalten falls kein Mechanismus betätigt werden muss
	if needsSwitch == false and isOn == true: power(true)
	else: power(false)
	lastState = isOn
	hide.free()
	var newHeight : float = 48 * length - 48
	var newPosition : float = newHeight / 2
	#COLLISION
	shapeCollision.position.x = shapeCollision.position.x + newPosition
	shapeCollision.shape.height = shapeCollision.shape.height + newHeight

func power(on : bool):
	var state : String
	var currentSpeed : int = speed
	match on:
		true: state = direction
		false: 
			state = "off"
			currentSpeed = 0
	for part in conveyorParts:
		for child in part.get_children():
			if child.name == "animation": child.play(state)
		if direction == "left": currentSpeed = currentSpeed - 2 * currentSpeed
		part.constant_linear_velocity.x = currentSpeed
		print(part.constant_linear_velocity.x)
	#if state != "off": pass

func _process(delta: float) -> void:
	if needsSwitch == true:
		if MechanismConnector.checkStatus(id) == true: isOn = true
		elif isOn == true: isOn = false
	if isOn != lastState:
		power(isOn)
		lastState = isOn
