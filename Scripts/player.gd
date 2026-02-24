extends CharacterBody2D

@export var defaultSpeed : int
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var maxVelocity : int
@export var pushForce : int
@export_enum("left", "right") var lastDirection : String

@onready var animation : AnimatedSprite2D = $Animation
@onready var rayCastDownLeft = $RayCastDownLeft
@onready var rayCastUpLeft = $RayCastUpLeft
@onready var rayCastDownRight = $RayCastDownRight
@onready var rayCastUpRight = $RayCastUpRight
@onready var rayCastBottomLeft = $RayCastBottomLeft
@onready var rayCastBottomRight = $RayCastBottomRight
@onready var rayCastTopLeft = $RayCastTopLeft
@onready var rayCastTopRight = $RayCastTopRight
#Die Reihenfolge der RayCasts ist WICHTIG! links unten > oben > rechts unten > oben
@onready var rayCasts : Array = [rayCastDownLeft, rayCastUpLeft, rayCastDownRight, rayCastUpRight]
@onready var leftRays : Array = [rayCastDownLeft, rayCastUpLeft, rayCastTopLeft]
@onready var rightRays : Array = [rayCastDownRight, rayCastUpRight, rayCastTopRight]
@onready var bottomRays : Array = [rayCastBottomLeft, rayCastBottomRight]
@onready var rayArrays : Array = [leftRays, rightRays, bottomRays]
var currentState : String = "idle"

#DEBUG
@onready var label = $Label

func _ready() -> void:
	idle()

func _physics_process(delta: float) -> void:
	checkDirection(delta)
	
func checkDirection(delta : float):
	var direction : float = Input.get_axis("LEFT", "RIGHT")
	match direction:
		-1.0: 
			animation.play("LEFT")
			lastDirection = "left"
		1.0: 
			animation.play("RIGHT")
			lastDirection = "right"
	statemachine(direction, delta)

func move(direction : float, delta : float, speed : int):
	#checkColisions() 
	velocity.y += gravity * delta
	velocity.x = direction * speed
	print("y: " + str(velocity.y) + " x: " + str(velocity.x))
	move_and_slide()

func statemachine(direction : float, delta : float):
	var collisions = getRayCollisions()
	var colliding : bool = false
	for ray in bottomRays:
		if collisions.has(ray): colliding = true
	match colliding:
		true: 
			if collisions.has(rayCastDownLeft) or collisions.has(rayCastDownRight):
				if collisions.has(rayCastUpLeft) or collisions.has(rayCastUpRight): currentState = "pushing"
				else: 
					if direction != 0.0: currentState = "sloping"
					else: currentState = "idle"
			else: 
				if direction != 0.0: currentState = "moving"
				else: currentState = "idle"
		false: currentState = "falling"
	label.text = currentState
	match currentState:
		"idle": idle() #wenn andere Animationen eingefügt werden hier stehen einfügen
		"moving": move(direction, delta, defaultSpeed) #wenn andere Animationen eingefügt werden hier bewegung einfügen
		"falling": 
			#vielleicht Fallanimation
			match direction:
				-1.0:
					if checkRayCollisions(leftRays, collisions) == true: 
						direction = 0.0
				1.0:
					if checkRayCollisions(rightRays, collisions) == true:
						direction = 0.0
			move(direction, delta, defaultSpeed)
		"pushing": 
			push()
			var pushingspeed = defaultSpeed / 2
			move(direction, delta, pushingspeed)
		"sloping": 
			slope()
			var slopingSpeed = 2 * defaultSpeed #defaultSpeed / 2 + defaultSpeed
			move(direction, delta, slopingSpeed)
	
func getRayCollisions() -> Array:
	var collisionList : Array
	for array in rayArrays:
		for ray in array:
			if ray.is_colliding(): collisionList.append(ray)
	return collisionList
	
func push():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("moveable") and abs(collider.get_linear_velocity().x) < maxVelocity: 
			collider.apply_central_impulse(collision.get_normal() * -pushForce)

func slope():
	for i in get_slide_collision_count():
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
			elif groundCollision == true and abs(collisionHight) < 5.0:
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
