extends CharacterBody2D

@export var defaultSpeed : int = 150
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var maxVelocity : int = 100
@export var pushForce : int = 90
@export_enum("left", "right") var lastDirection : String

@onready var animation : AnimatedSprite2D = $Animation
@onready var rayCastDownLeft : RayCast2D = $RayCastDownLeft
@onready var rayCastDownRight : RayCast2D = $RayCastDownRight
@onready var rayCastBottomLeft : RayCast2D = $RayCastBottomLeft
@onready var rayCastBottomRight : RayCast2D = $RayCastBottomRight
#Die Reihenfolge der RayCasts ist WICHTIG! links unten > oben > rechts unten > oben
@onready var rayCasts : Array[RayCast2D] = [rayCastDownLeft, rayCastDownRight]
var currentState : String = "idle"
var interacting : bool = false

#DEBUG
@onready var label = $Label

func _ready() -> void:
	idle()
	add_to_group("player")

func _physics_process(delta: float) -> void:
	checkDirection(delta)
	
func checkDirection(delta : float):
	var direction : float
	if interacting == true: direction = 0.0
	else: direction = Input.get_axis("LEFT", "RIGHT")
	match direction:
		-1.0: 
			animation.play("LEFT")
			#lastDirection = "left"
		1.0: 
			animation.play("RIGHT")
			#lastDirection = "right"
		0.0: animation.stop()
	statemachine(direction, delta)

func move(direction : float, delta : float, speed : int):
	var addedSpeed : int
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider != null:
			if collider.is_in_group("conveyor"): addedSpeed = collider.speed
	speed = speed + addedSpeed
	velocity.y += gravity * delta
	velocity.x = direction * speed
	move_and_slide()
	
func statemachine(direction : float, delta : float):
	match direction:
		0.0: currentState = "idle"
		_: currentState = "moving"
	if interacting == true: currentState = "interacting"
	else:
		if get_slide_collision_count() != 0:
			if not rayCastBottomLeft.is_colliding() and not rayCastBottomRight.is_colliding(): 
				currentState = "falling"
			for i in get_slide_collision_count():
				var collision = get_slide_collision(i)
				var collider = collision.get_collider()
				if collider != null:
					if collider.is_in_group("moveable"): 
						var ray : RayCast2D
						if rayCastBottomLeft.is_colliding(): ray = rayCastBottomLeft
						elif rayCastBottomRight.is_colliding(): ray = rayCastBottomRight
						if ray != null:
							var bottomCollider = ray.get_collider()
							if bottomCollider != collider: currentState = "pushing"
			if rayCastDownLeft.is_colliding() or rayCastDownRight.is_colliding(): 
				if direction != 0.0: 
					var ray : RayCast2D
					if rayCastDownLeft.is_colliding(): ray = rayCastDownLeft
					elif rayCastDownRight.is_colliding(): ray = rayCastDownRight
					var collider = ray.get_collider()
					if collider != null:
						if not collider.is_in_group("moveable"): currentState = "sloping"
		else: currentState = "falling"
	label.text = currentState
	var moveSpeed : int = defaultSpeed
	match currentState:
		"idle": 
			idle() #wenn andere Animationen eingefügt werden hier stehen einfügen
			moveSpeed = 0
		"moving": pass #move(direction, delta, defaultSpeed) #wenn andere Animationen eingefügt werden hier bewegung einfügen
		"falling": pass #move(direction, delta, defaultSpeed) #vielleicht Fallanimation
		"pushing": push() #move(direction, delta, defaultSpeed)
		"sloping": 
			slope()
			moveSpeed = 2 * defaultSpeed
		"interacting": pass #interactionsanimation?
	if interacting == false: move(direction, delta, moveSpeed)
	
func push():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("moveable") and abs(collider.get_linear_velocity().x) < maxVelocity: 
			collider.apply_central_impulse(collision.get_normal() * -pushForce) #von _impulse auf _force geändert um etwas zu testen

func slope():
	for i in get_slide_collision_count():
		print("yes actually")
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var groundCollision : bool = false
		var collisionHight : float
		var destinationY : float
		for rayCast in rayCasts:
			#wenn rayCast eine Kollision erkennt
			if rayCast.is_colliding():
				collisionHight = collider.position.y - rayCast.get_collision_point().y
				groundCollision = true
				destinationY = collider.position.y - 24.0
			#wenn der rayCast oben nichts erkennt und ledge nicht zu hoch ist
			#Das ist wichtig, weil der RayCast unten sonst auch eine Bodenkollision erkennt wenn eine Box geschoben wird
			if groundCollision == true and abs(collisionHight) < 5.0:
				position.y = destinationY
				groundCollision = false

func checkRayCollisions(rays : Array, collisions : Array) -> bool:
	for ray in rays:
		if collisions.has(ray): return true
	return false

func idle():
	match lastDirection:
		"left": animation.play("IDLE LEFT")
		"right": animation.play("IDLE RIGHT")
