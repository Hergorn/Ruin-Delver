extends Node2D

@export_enum("left", "right") var direction : String
@export var needsSwitch : bool
@export var isOn : bool
@export var length : int #unter 2 wird automatisch auf 2 gesetzt
@export var id : int

@onready var leftPart : StaticBody2D = $hidden/leftPart
@onready var middlePart : StaticBody2D = $hidden/middlePart
@onready var rightPart : StaticBody2D = $hidden/rightPart
@onready var body : Node2D = $body

var conveyorParts : Array
var lastState : bool

func _ready() -> void:
	#Aufbau
	if length < 2: length = 2
	for i in length:
		var currentPart : int = length - i
		var lastPart : int = length + 1
		var newPart : StaticBody2D
		match currentPart:
			length: newPart =  leftPart.duplicate()
			1: newPart =  rightPart.duplicate()
			_: newPart =  middlePart.duplicate()
		newPart.position.x = i * 48
		body.add_child(newPart)
		conveyorParts.append(newPart)
	#Einschalten falls kein Mechanismus betätigt werden muss
	if needsSwitch == false and isOn == true: power(true)
	else: power(false)
	lastState = isOn
			
func power(on : bool):
	var state : String
	match on:
		true: state = direction
		false: state = "off"
	for part in conveyorParts:
		for child in part.get_children():
			if child.name == "animation": child.play(state)

func _process(delta: float) -> void:
	if needsSwitch == true:
		if MechanismConnector.checkStatus(id) == true: isOn = true
		elif isOn == true: isOn = false
		if isOn != lastState:
			power(isOn)
			lastState = isOn
