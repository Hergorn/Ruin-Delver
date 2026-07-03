extends Node2D

@export var isOn : bool
@export var length : int
@export_enum("vertical", "horizontal") var orientation : String
@export var needsSwitch : bool
@export var id : int
@export_enum("vertical", "horizontal") var pathOrientation : String
@export var pathLength : int
@export var customPath : bool
@export var speed : float = 0.2

@onready var hide : Node2D = $hidden
@onready var platformBody : Node2D = $platformBody
@onready var firstPart : StaticBody2D = $hidden/firstPart
@onready var middlePart : StaticBody2D = $hidden/middlePart
@onready var lastPart : StaticBody2D = $hidden/lastPart
@onready var singlePart : StaticBody2D = $hidden/singlePart
@onready var pathfollow : PathFollow2D = $PathFollow
@onready var forwardDirection = 1
@onready var path : Path2D = $"."
@onready var crystal = preload("res://Scenes/crystal.tscn").instantiate()

func _ready() -> void:
	hide.visible = false
	for child in hide.get_children(): 
		child.position.x = 0
		child.position.y = 0
	aufbau()
	if customPath == false: createPath()
	if needsSwitch == true: platformBody.add_child(crystal)

		
	

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
				platformBody.add_child(newPart)

func setPartPosition(part : StaticBody2D, i : int):
	match orientation:
		"horizontal": part.position = Vector2 (i * 48, 0)
		"vertical": 
			part.position = Vector2(0, i * 48)
			part.rotation = deg_to_rad(90.0)

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	pathfollow.progress_ratio += speed * delta * forwardDirection
	
	if forwardDirection == 1 and pathfollow.progress_ratio == 1:
		forwardDirection = -1
	elif forwardDirection == -1 and pathfollow.progress_ratio == 0: 
		forwardDirection = 1
	print(platformBody.position)

func createPath():
	for i in pathLength:
		match pathOrientation:
			"horizontal":  path.curve.add_point(Vector2(i*48,0))
			"vertical": path.curve.add_point(Vector2(0,i*-48))
