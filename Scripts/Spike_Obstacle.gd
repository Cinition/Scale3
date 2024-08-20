extends StaticBody2D

@onready var Collision = $SpikeCollision

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quebert_area_body_entered(body: Node2D) -> void:
	var qubert := body as Qubert
	if not qubert:
		return
	
	qubert._kill()
	print("Qubert ded")
