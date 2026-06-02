extends Node2D

@export var length : int
@export_enum("vertical", "horizontal") var orientation : String
@export_enum("blue", "red") var color : String

@onready var firstPart : AnimatedSprite2D = $Hidden/FirstPart
@onready var middlePart : AnimatedSprite2D = $Hidden/MiddlePart
@onready var lastPart : AnimatedSprite2D = $Hidden/LastPart
@onready var doorBody : Node2D = $Body
@onready var hide : Node2D = $Hidden

func _ready() -> void:
	hide.visible = false
	#seting colors
	for child in hide.get_children(): child.position = Vector2(0,0)
	aufbau()
	var frameId : int = 1
	var isMiddle : bool = false
	for childId in doorBody.get_child_count(): 
		doorBody.get_child(childId).play(color)
		var childName = doorBody.get_child(childId).name
		if isMiddle == true and childName != "FirstPart" and childName != "LastPart":
			frameId = frameId - 1
			if frameId == -1: frameId = 2
		if childName != "FirstPart" and childName != "LastPart": isMiddle = true
		else: isMiddle = false
		doorBody.get_child(childId).frame = frameId
		
	
func aufbau():
	if length < 3: length = 3
	for i in length:
		var currentPart : int = length - i
		var newPart : AnimatedSprite2D
		match currentPart:
			length: newPart =  firstPart.duplicate()
			1: newPart =  lastPart.duplicate()
			_: newPart =  middlePart.duplicate()
		setPartPosition(newPart, i)
		print(newPart.position)
		doorBody.add_child(newPart)

func setPartPosition(part : AnimatedSprite2D, i : int):
	match orientation:
		"horizontal": part.position.x = i * 48
		"vertical": 
			part.position.y = i * 48 
			part.rotation = deg_to_rad(90.0)
