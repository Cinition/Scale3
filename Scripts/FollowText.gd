extends Label

@export var Target: Node2D

var Follow = false

func _physics_process(delta: float) -> void:
	if Follow == true:
		self.position.x = Target.position.x - (self.size.x / 2)
	elif Target.position.x - (self.size.x / 2) > self.position.x:
		Follow = true
