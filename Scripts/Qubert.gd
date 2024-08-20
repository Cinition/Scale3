@tool
class_name Qubert
extends CharacterBody2D

@onready var CollisionShape = $CollisionShape2D
@onready var MeshInstance   = $MeshInstance2D
@onready var AnimPlayer     = $AnimationPlayer

@export_subgroup("Variables")
@export var MovementSpeed: float
@export var JumpStrength:  float
@export_flags_2d_physics var DefaultCollisionMask

@export_subgroup("Scaled up Variables")
@export var BigJumpStrength: float
@export var BigFallingStrength: float
@export var BigJumpMovementSpeed: float
@export_flags_2d_physics var BigFallingCollisionMask

@export_subgroup("Scaled down Variables")
@export var SlidingDuration:      float
@export var SlidingMovementSpeed: float
@export_exp_easing var SlidingMovementCurve = 1.0

@warning_ignore("unused_signal") # Used by UI
signal qubert_died

enum QubertSize      {
	LARGE,
	NORMAL,
	SMALL
}
enum QubertAnimation {
	BIGJUMP,
	BIGREJUMP,
	BIGSLAM,
	BIGFALLING,
	FALLING,
	JUMP,
	BEGINSMALLSLIDE,
	SMALLSLIDE,
	IDLE
}

var CurrentQubertSize      = QubertSize.NORMAL
var CurrentQubertAnimation = QubertAnimation.IDLE
var GoingRight             = true
var SlidingTimer           = 0.0
var JumpedInAir            = false
var ScaledUpInAir          = false
var ScaledDownInAir        = false
var RequestSpeed           = 0.0
var CaptureMovementSpeed   = 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	self.collision_mask = DefaultCollisionMask


func _kill() -> void:
	self.queue_free()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	HandleAnimation(delta)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if is_on_floor():
		JumpedInAir     = false
		ScaledUpInAir   = false
		ScaledDownInAir = false

	# Handle gravity
	if not is_on_floor():
		if CurrentQubertAnimation == QubertAnimation.BEGINSMALLSLIDE or CurrentQubertAnimation == QubertAnimation.SMALLSLIDE:
			if velocity.y < 0:
				velocity += get_gravity() * delta
			else:
				velocity.y = 0
		elif CurrentQubertAnimation == QubertAnimation.BIGFALLING:
			velocity.y += BigFallingStrength
		else:
			velocity += get_gravity() * delta
			if velocity.y > 0:
				if CurrentQubertAnimation == QubertAnimation.BIGJUMP or CurrentQubertAnimation == QubertAnimation.BIGREJUMP:
					CurrentQubertAnimation = QubertAnimation.BIGFALLING
				else:
					CurrentQubertAnimation = QubertAnimation.FALLING

	# Move Qubert to the right
	if CurrentQubertAnimation == QubertAnimation.BIGFALLING:
		RequestSpeed = 0.0
	elif CurrentQubertAnimation == QubertAnimation.BIGJUMP:
		CaptureMovementSpeed = lerpf(CaptureMovementSpeed, BigJumpMovementSpeed, 0.01)
		RequestSpeed = CaptureMovementSpeed if GoingRight else -CaptureMovementSpeed
	elif CurrentQubertAnimation == QubertAnimation.SMALLSLIDE:
		var easedValue = ease(SlidingTimer / SlidingDuration, SlidingMovementCurve)
		var speed      = MovementSpeed + (SlidingMovementSpeed - MovementSpeed) * easedValue
		RequestSpeed   = speed if GoingRight else -speed
	elif is_on_floor():
		RequestSpeed = MovementSpeed if GoingRight else -MovementSpeed

	# Handle jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		Jump()

	if Input.is_action_just_pressed("Jump") and JumpedInAir == false:
		JumpedInAir = true
		Jump()

	# Scale up
	if Input.is_action_just_pressed("ScaleQubertUp") and (CurrentQubertAnimation != QubertAnimation.BIGJUMP and CurrentQubertAnimation != QubertAnimation.BIGFALLING ):
		if is_on_floor():
			BigJump()
			CaptureMovementSpeed = RequestSpeed
		elif ScaledUpInAir == false:
			BigJump()
			ScaledUpInAir = true
			CaptureMovementSpeed = RequestSpeed

	# Scale down
	if Input.is_action_just_pressed("ScaleQubertDown") and (CurrentQubertAnimation != QubertAnimation.BEGINSMALLSLIDE and CurrentQubertAnimation != QubertAnimation.SMALLSLIDE):
		if is_on_floor():
			CurrentQubertAnimation = QubertAnimation.BEGINSMALLSLIDE
		elif ScaledDownInAir == false:
			CurrentQubertAnimation = QubertAnimation.BEGINSMALLSLIDE
			ScaledDownInAir = true

	# lerp to velocity
	velocity.x = lerpf(velocity.x, RequestSpeed, 0.05)

	# Apply velocity
	move_and_slide()


func Jump() -> void:
	velocity.y = -JumpStrength
	CurrentQubertAnimation = QubertAnimation.JUMP


func Slam() -> void:
	velocity.y = -JumpStrength


func BigJump() -> void:
	velocity.x = 0.0
	velocity.y = -BigJumpStrength
	CurrentQubertAnimation = QubertAnimation.BIGJUMP


func HandleAnimation(delta: float) -> void:
	if CurrentQubertAnimation == QubertAnimation.IDLE:
		CurrentQubertSize = QubertSize.NORMAL
		if AnimPlayer.current_animation != "QubertAnimations/IDLE":
			AnimPlayer.play("QubertAnimations/IDLE")

	if CurrentQubertAnimation == QubertAnimation.BIGJUMP:
		CurrentQubertSize = QubertSize.NORMAL
		if AnimPlayer.current_animation != "QubertAnimations/BIGJUMP":
			AnimPlayer.play("QubertAnimations/BIGJUMP")

	if CurrentQubertAnimation == QubertAnimation.BIGFALLING:
		collision_mask   = BigFallingCollisionMask
		CurrentQubertSize = QubertSize.LARGE
		if AnimPlayer.current_animation != "QubertAnimations/BIGFALLING":
			AnimPlayer.play("QubertAnimations/BIGFALLING")

		if is_on_floor():
			CurrentQubertAnimation = QubertAnimation.BIGSLAM
			Slam()

	if CurrentQubertAnimation == QubertAnimation.BIGSLAM:
		collision_mask   = DefaultCollisionMask
		CurrentQubertSize = QubertSize.NORMAL
		if AnimPlayer.current_animation != "QubertAnimations/BIGSLAM":
			AnimPlayer.play("QubertAnimations/BIGSLAM")

	if CurrentQubertAnimation == QubertAnimation.FALLING:
		CurrentQubertSize = QubertSize.NORMAL
		if AnimPlayer.current_animation != "QubertAnimations/FALLING":
			AnimPlayer.play("QubertAnimations/FALLING")

		if self.is_on_floor():
			CurrentQubertAnimation = QubertAnimation.IDLE

	if CurrentQubertAnimation == QubertAnimation.JUMP:
		CurrentQubertSize = QubertSize.NORMAL
		if AnimPlayer.current_animation != "QubertAnimations/JUMP":
			AnimPlayer.play("QubertAnimations/JUMP")

	if CurrentQubertAnimation == QubertAnimation.BEGINSMALLSLIDE:
		CurrentQubertSize = QubertSize.NORMAL
		if AnimPlayer.current_animation != "QubertAnimations/BEGINSMALLSLIDE":
			AnimPlayer.play("QubertAnimations/BEGINSMALLSLIDE")

		if self.is_on_wall():
			CurrentQubertAnimation = QubertAnimation.IDLE

	if CurrentQubertAnimation == QubertAnimation.SMALLSLIDE:
		CurrentQubertSize = QubertSize.SMALL
		if AnimPlayer.current_animation != "QubertAnimations/SMALLSLIDE":
			AnimPlayer.play("QubertAnimations/SMALLSLIDE")
			SlidingTimer = 0.0

		if self.is_on_wall():
			CurrentQubertAnimation = QubertAnimation.IDLE

		if SlidingTimer > SlidingDuration:
			if is_on_floor():
				Jump()
			else:
				CurrentQubertAnimation = QubertAnimation.IDLE

		SlidingTimer += delta


func OnAnimationFinished(anim_name: StringName) -> void:
	if anim_name == "QubertAnimations/BIGJUMP":
		CurrentQubertAnimation = QubertAnimation.BIGFALLING

	if anim_name == "QubertAnimations/BIGSLAM":
		CurrentQubertAnimation = QubertAnimation.IDLE

	if anim_name == "QubertAnimations/BEGINSMALLSLIDE":
		CurrentQubertAnimation = QubertAnimation.SMALLSLIDE

	if anim_name == "QubertAnimations/SMALLSLIDE":
		CurrentQubertAnimation = QubertAnimation.IDLE

	if anim_name == "QubertAnimations/JUMP":
		CurrentQubertAnimation = QubertAnimation.IDLE
