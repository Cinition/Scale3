extends Area2D

@export var Target: Node2D

func _on_body_entered(body: Node2D) -> void:
	var qubert := body as Qubert
	if not qubert:
		return
	
	if not Target:
		return

	var inOffset    = qubert.position - position
	qubert.position = Target.position + inOffset
