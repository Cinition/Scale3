extends StaticBody2D

@onready var Collision = $FloorCollision
@onready var Sprite = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quebert_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Qubert"):
		print("Qubert detetced")
		Collision.call_deferred("set_disabled", true)
		Sprite.visible = false
	
