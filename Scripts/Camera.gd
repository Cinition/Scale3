extends Camera2D

@export var Target: Node2D

func _physics_process(delta: float) -> void:
	var NewPosition = lerp(position, Target.position, 0.25)
	position = NewPosition
