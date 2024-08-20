extends Area2D

signal qubert_finished

func _on_body_entered(body: Node2D) -> void:
	var qubert := body as Qubert
	if not qubert:
		return
	
	qubert_finished.emit()
