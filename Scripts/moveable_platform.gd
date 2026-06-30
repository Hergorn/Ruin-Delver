extends Node2D

@export var isOn : bool
@export var length : int
@export_enum("vertical", "horizontal") var orientation : String
@export var needsSwitch : bool
@export var id : int

@onready var hide : Node2D = $hidden
@onready var platformBody : Node2D = $platformBody
@onready var firstPart : StaticBody2D = $hidden/firstPart
@onready var middlePart : StaticBody2D = $hidden/middlePart
@onready var lastPart : StaticBody2D = $hidden/lastPart
@onready var singlePart : StaticBody2D = $hidden/singlePart

##testing
@onready var pathfollow : PathFollow2D = $TEST/Path2D/PathFollow2D
@onready var speed : float = 0.2
@onready var forwardDirection = 1
##testing

func _ready() -> void:
	hide.visible = false
	for child in hide.get_children(): child.position = Vector2(0,0)
	aufbau()
		
func aufbau():
	if length == 0: length = 1
	var newPart : StaticBody2D
	match length:
		1: 
			newPart = singlePart.duplicate()
			setPartPosition(newPart, 0)
			platformBody.add_child(newPart)
		_:
			for i in length:
				var currentPart : int = length - i
				match currentPart:
					length: newPart =  firstPart.duplicate()
					1: newPart =  lastPart.duplicate()
					_: newPart =  middlePart.duplicate()
				setPartPosition(newPart, i)
				print(newPart.position)
				platformBody.add_child(newPart)

func setPartPosition(part : StaticBody2D, i : int):
	match orientation:
		"horizontal": part.position.x = i * 48
		"vertical": 
			part.position.y = i * 48 
			part.rotation = deg_to_rad(90.0)

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	pathfollow.progress_ratio += speed * delta * forwardDirection
	
	if forwardDirection == 1 and pathfollow.progress_ratio == 1:
		forwardDirection = -1
	elif forwardDirection == -1 and pathfollow.progress_ratio == 0: 
		forwardDirection = 1
