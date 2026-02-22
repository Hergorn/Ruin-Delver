extends CharacterBody2D

@export var speed : int
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var maxVelocity : int
@export var pushForce : int
@onready var animation : AnimatedSprite2D = $Animation
#Die Reihenfolge der RayCasts ist WICHTIG! links unten > oben > rechts unten > oben
@onready var rayCasts : Array = [$RayCastDownLeft, $RayCastUpLeft, $RayCastDownRight, $RayCastUpRight]

func _physics_process(delta: float) -> void:
	checkDirection(delta)
	
func checkDirection(delta : float):
	var direction : float = Input.get_axis("LEFT", "RIGHT")
	match direction:
		-1.0: animation.play("LEFT")
		1.0: animation.play("RIGHT")
		_: animation.stop()
	move(direction, delta)

func move(direction : float, delta : float): 
	velocity.y += gravity * delta
	velocity.x = direction * speed
	checkColisions()
	move_and_slide()
	
func checkColisions():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		#dinge schieben
		if collider.is_in_group("moveable") and abs(collider.get_linear_velocity().x) < maxVelocity:
			collider.apply_central_impulse(collision.get_normal() * -pushForce)
		#kleine ledges hoch kommen
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
