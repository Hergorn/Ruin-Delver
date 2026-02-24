extends AnimatedSprite2D

@export var id : int
@export_enum("horizontal", "vertical") var direction : String
var isOn : bool = false
var lastState : bool = false

func _ready() -> void:
	if MechanismConnector.checkStatus(id) == true: isOn = true
	elif isOn == true: isOn = false
	changeAnimation()

func _process(delta: float) -> void:
	if MechanismConnector.checkStatus(id) == true: isOn = true
	elif isOn == true: isOn = false
	if isOn != lastState:
		changeAnimation()
		lastState = isOn
		
func changeAnimation():
	match isOn:
			true:
				match direction:
					"horizontal": play("horizontal on")
					"vertical": play("vertical on")
			false:
				match direction:
					"horizontal": play("horizontal off")
					"vertical": play("vertical off")
