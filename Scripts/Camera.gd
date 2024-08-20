extends Camera2D

@export var Target: Node2D
@export var QubertOffset: Vector2

func _physics_process(delta: float) -> void:
	if not Target:
		return

	var NewPosition = lerp(position - QubertOffset, Target.position, 0.2)
	position = Vector2(Target.position.x, NewPosition.y) + QubertOffset
