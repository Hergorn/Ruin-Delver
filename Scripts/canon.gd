extends Node2D

# KanonenPosition - 0 ist oben Minus Richtung ist Links Plus richtung ist Rechts
@export_enum("-3","-2", "-1", "0", "1", "2", "3", "4") var canonPosition : String
# Bein Position. 0 ist unten. dreht sich jeweils um 90° im Uhrzeiger
@export_enum("0", "1", "2", "3") var legPosition : int
@export var moveable : bool
@export var shootforce : int = 900

@onready var canonBody : Sprite2D = $CanonBody
@onready var canonLeg : Sprite2D = $CanonLeg
@onready var detectionArea : Area2D = $DetectionArea
@onready var inputE : AnimatedSprite2D = $InputE
@onready var spawnpoint : Marker2D = $SpawnPosition
@onready var inputA : AnimatedSprite2D = $InputA
@onready var inputD : AnimatedSprite2D = $InputD
@onready var inputQ : AnimatedSprite2D = $InputQ
@onready var inputs : Array[AnimatedSprite2D] = [inputA, inputD, inputQ]

@onready var bodies : Array = []
@onready var moveableHere : bool = false
@onready var playerHere : bool = false
@onready var amunition : Array = []
@onready var loaded : bool = false
@onready var canonY : int
@onready var shootingDirection : Vector2
@onready var handled : bool = false

func _ready() -> void:
	setObjectRotation(canonBody, 45, float(canonPosition))
	setObjectRotation(canonLeg, 90, float(legPosition))
	match moveable:
		true: canonY = 0
		false: canonY = 48
	setAtlasTexture(canonBody, 48)
	setAtlasTexture(canonLeg, 0)
	inputE.play("default")
	for input in inputs: input.play("default")
	setShootingDirection()

func setAtlasTexture(sprite : Sprite2D, x : int):
	var atlas : AtlasTexture = AtlasTexture.new()
	atlas.atlas = preload("res://ASSETS/Tilesets/Canons.png")
	atlas.region = Rect2(x, canonY, 48, 48)
	sprite.texture = atlas

func setObjectRotation(sprite : Sprite2D, degrees : float, position : float):
	var objectRotation = position * degrees
	sprite.rotation = deg_to_rad(objectRotation)

func _process(delta: float) -> void:
	var moveables : int = 0
	var players : int = 0
	for body in bodies:
		if body.is_in_group("moveable"): moveables = moveables + 1
		elif body.is_in_group("player"): players = players + 1
	match moveables:
		0: moveableHere = false
		_: moveableHere = true
	match players:
		0: playerHere = false
		_: playerHere = true
	if playerHere == true and moveableHere == true or loaded == true and playerHere == true:
		inputE.visible = true
	else: inputE.visible = false
	if inputE.visible == true:
		if Input.is_action_just_pressed("INTERACT"):
			match loaded:
				false:
					while loaded == false:
						for body in bodies:
							if body.is_in_group("moveable"): 
								amunition.append(body.objectMaterial)
								loaded = true
								body.queue_free()
								toggleCanon(true)
				true:
					if moveable == true and handled == false: 
						handled = true
						for body in bodies:
							if body.is_in_group("player"): body.interacting = true
					elif moveable == false or handled == true:
						var objectScene : PackedScene = load("res://Scenes/object.tscn")
						var objectInstance : Node2D = objectScene.instantiate()
						objectInstance.position = spawnpoint.position
						objectInstance.objectMaterial = amunition[0]
						add_child(objectInstance)
						amunition.erase(amunition[0])
						loaded = false
						toggleCanon(false)
						objectInstance.apply_central_impulse(shootingDirection)
	for input in inputs: input.visible = handled
	if handled == true:
		if Input.is_action_just_pressed("LEFT"): 
			var newCanonPosition = int(canonPosition) -1
			if newCanonPosition == -4: newCanonPosition = 4
			canonPosition = str(newCanonPosition)
			setShootingDirection()
			setObjectRotation(canonBody, 45, float(canonPosition))
		elif Input.is_action_just_pressed("RIGHT"):
			var newCanonPosition = int(canonPosition) +1
			if newCanonPosition == 5: newCanonPosition = -3
			canonPosition = str(newCanonPosition)
			setShootingDirection()
			setObjectRotation(canonBody, 45, float(canonPosition))
		elif Input.is_action_just_pressed("QUIT"): 
			handled = false
			for body in bodies:
				if body.is_in_group("player"): body.interacting = false

func setShootingDirection():
	match canonPosition:
		"-3": 
			shootingDirection = Vector2(-shootforce, shootforce)
			spawnpoint.position = Vector2(-36, 36)
		"-2": 
			shootingDirection = Vector2(-shootforce, 0)
			spawnpoint.position = Vector2(-36, 0)
		"-1": 
			shootingDirection = Vector2(-shootforce, -shootforce)
			spawnpoint.position = Vector2(-36, -36)
		"0": 
			shootingDirection = Vector2(0, -shootforce)
			spawnpoint.position = Vector2(0, -36)
		"1": 
			shootingDirection = Vector2(shootforce, -shootforce)
			spawnpoint.position = Vector2(36, -36)
		"2": 
			shootingDirection = Vector2(shootforce, 0)
			spawnpoint.position = Vector2(36, 0)
		"3": 
			shootingDirection = Vector2(shootforce, shootforce)
			spawnpoint.position = Vector2(36, 36)
		"4": 
			shootingDirection = Vector2(0, shootforce)
			spawnpoint.position = Vector2(0, 36)

func _on_detection_area_body_entered(body: Node2D) -> void:
	bodies.append(body)

func _on_detection_area_body_exited(body: Node2D) -> void:
	bodies.erase(body)

func toggleCanon(on : bool):
	match on:
		true: setAtlasTexture(canonBody, 96)
		false: setAtlasTexture(canonBody, 48)
	
