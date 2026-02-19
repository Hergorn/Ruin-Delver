extends CharacterBody2D

@export var speed : int
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var maxVelocity : int
@export var pushForce : int

func _physics_process(delta: float) -> void:
	checkDirection(delta)
	
func checkDirection(delta : float):
	var direction = Input.get_axis("LEFT", "RIGHT")
	match direction:
		-1.0: $Animation.play("LEFT")
		1.0: $Animation.play("RIGHT")
		_: $Animation.stop()
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
		if collider.is_in_group("moveable") and abs(collider.get_linear_velocity().x) < maxVelocity:
			collider.apply_central_impulse(collision.get_normal() * -pushForce)
			
