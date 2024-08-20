extends Camera2D

@export var Target:       Node2D
@export var QubertOffset: Vector2
@export var ZoomInSize:   Vector2
@export var ZoomOutSize:  Vector2

var DeltaZoom: Vector2

func _ready() -> void:
	DeltaZoom = self.zoom

func _physics_process(delta: float) -> void:
	if not Target:
		return

	var NewPosition = lerp(position - QubertOffset, Target.position, 0.2)
	position = Vector2(Target.position.x, NewPosition.y) + QubertOffset

	var qubert = Target as Qubert
	if not qubert:
		return

	var speedLerp = qubert.velocity.x / qubert.SlidingMovementSpeed
	var cameraLerp = lerp(ZoomInSize, ZoomOutSize, speedLerp)
	
	DeltaZoom = lerp(DeltaZoom, cameraLerp, 0.01)
	
	self.zoom = DeltaZoom
