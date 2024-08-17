extends StaticBody2D

@export var LaunchStrength:  float = 500
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_qubert_area_body_entered(body: Node2D) -> void:
	var qubert := body as Qubert
	if not qubert:
		return

	if qubert.CurrentQubertSize != qubert.QubertSize.SMALL:
		return

	qubert.velocity.y = -LaunchStrength
