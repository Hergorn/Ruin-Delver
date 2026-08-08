extends Node2D

@export var isOn : bool
@export var length : int
@export_enum("vertical", "horizontal") var orientation : String
@export var needsSwitch : bool
@export var id : int
@export var pathLength : int
@export var duration : float
@export_enum("left","right","up","down") var direction : String

@onready var hide : Node2D = $hidden
@onready var platformBody : Node2D = $platformBody
@onready var firstPart : StaticBody2D = $hidden/firstPart
@onready var middlePart : StaticBody2D = $hidden/middlePart
@onready var lastPart : StaticBody2D = $hidden/lastPart
@onready var singlePart : StaticBody2D = $hidden/singlePart
@onready var crystal = preload("res://Scenes/crystal.tscn").instantiate()
@onready var idState : bool
@onready var tweens : Array[Tween]
@onready var originPositions : Array[Vector2]

func _ready() -> void:
	hide.visible = false
	for child in hide.get_children(): 
		child.position.x = 0
		child.position.y = 0
	aufbau()
	for child in hide.get_children():
		hide.remove_child(child)
		child.queue_free()
	if needsSwitch == true: 
		crystal.position = Vector2(length * 24 - 24, 0)
		crystal.id = id
		crystal.scale = Vector2(0.6, 0.6)
		platformBody.add_child(crystal)
		idState = MechanismConnector.checkStatus(id)
	if isOn == true: checkTween()

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

func toggleOn():
	match isOn:
		true: isOn = false
		false: isOn = true
		
func tweenPlatform():
	var offset : float = pathLength * 48
	if direction == "left" or direction == "up": offset = 0 - offset
	if direction == "up" or direction == "down":
		for child in platformBody.get_children():
			var originY = child.position.y
			var tween : Tween
			tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			tween.set_loops().set_parallel(false)
			tween.tween_property(child, "position", Vector2(child.position.x , originY + offset), duration / 2)
			tween.tween_property(child, "position", Vector2(child.position.x , originY), duration / 2)
			tweens.append(tween)
			originPositions.append(Vector2(child.position.x , originY))
	elif direction == "right" or direction == "left":
		for child in platformBody.get_children():
			var originX = child.position.x
			var tween : Tween
			tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			tween.set_loops().set_parallel(false)
			tween.tween_property(child, "position", Vector2(originX + offset , child.position.y), duration / 2)
			tween.tween_property(child, "position", Vector2(originX , child.position.y), duration / 2)
			tweens.append(tween)
			originPositions.append(Vector2(originX, child.position.y))

func _physics_process(delta: float) -> void:
	var checkState : bool = MechanismConnector.checkStatus(id)
	if idState != checkState:
		idState = checkState
		toggleOn()
		checkTween()
	for child in platformBody.get_children(): child.global_position = child.global_position
		
func checkTween():
	match isOn:
		true: tweenPlatform()
		false: 
			await reverseTweens()
			clearTweens()
		
func reverseTweens():
	for tween in tweens: tween.kill()
	tweens = []
	var i : int = 0
	for child in platformBody.get_children():
		var tween : Tween
		tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tween.set_parallel(false)
		tween.tween_property(child, "position", originPositions[i], duration / 2)
		i = i + 1
		tweens.append(tween)
	await tweens[0].finished

func clearTweens():
	if platformBody.get_child(0).position == originPositions[0]:
		tweens = []
		originPositions = []
	else: print("ERROR IN TWEEN AND AWAIT PARSING")
