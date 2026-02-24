extends Node2D
@export_enum("bottom", "left", "top", "right") var gateStartDirection : String
@export_enum("bottom", "left", "top", "right") var gateOpenDirection : String
@export_enum("bottom", "left", "top", "right") var mechanismDirection : String
@export var id : int
@onready var mechanism : StaticBody2D = $mechanism
@onready var gate : Node2D = $gate
@onready var gateStartDegrees : float
@onready var gateOpenDegrees : float
var isOn : bool = false
var lastState : bool = false

func _ready() -> void:
	match mechanismDirection:
		"bottom": mechanism.rotation_degrees = 0.0
		"left": mechanism.rotation_degrees = 90.0
		"top": mechanism.rotation_degrees = 180.0
		"right": mechanism.rotation_degrees = 270.0
	match gateStartDirection:
		"bottom": gateStartDegrees = 180.0
		"left": gateStartDegrees = 270.0
		"top": gateStartDegrees = 0.0
		"right": gateStartDegrees = 90.0
	match gateOpenDirection:
		"bottom": gateOpenDegrees = 180.0
		"left": gateOpenDegrees = -90.0
		"top": gateOpenDegrees = 0.0
		"right": gateOpenDegrees = 90.0
	gate.rotation_degrees = gateStartDegrees

func _process(delta: float) -> void:
	if MechanismConnector.checkStatus(id) == true: isOn = true
	else: isOn = false
	if isOn == true and lastState != isOn:
		var tween := create_tween()
		tween.tween_property(gate, "rotation_degrees", gateOpenDegrees, 0.2)
		lastState = isOn
	elif isOn == false and lastState != isOn:
		var tween := create_tween()
		tween.tween_property(gate, "rotation_degrees", gateStartDegrees, 0.2)
		lastState = isOn
