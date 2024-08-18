@tool
class_name Qubert
extends CharacterBody2D

@onready var CollisionShape = $CollisionShape2D
@onready var MeshInstance   = $MeshInstance2D
@onready var AnimPlayer     = $AnimationPlayer

@export_category("Variables")
@export var MovementSpeed: float
@export var JumpStrength:  float

@export_category("Scaled up Variables")
@export var BigJumpStrength: float
@export var CoyoteTimeDuration: float

@export_category("Scaled down Variables")
@export var SlidingDuration:      float
@export var SlidingMovementSpeed: float

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

var CurrentQubertSize         = QubertSize.NORMAL
var CurrentQubertAnimation    = QubertAnimation.IDLE
var GoingRight                = true
var HasAlreadyScaledUpInAir   = false
var HasAlreadyScaledDownInAir = false
var AnimationCoyoteEnable     = false
var AnimationCoyoteTimer      = 0.0
var SlidingTimer              = 0.0

func _ready() -> void:
	pass


func _kill() -> void:
	self.queue_free()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	HandleAnimation(delta)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	print(velocity)

	# Handle gravity
	if not is_on_floor():
		if CurrentQubertAnimation != QubertAnimation.BEGINSMALLSLIDE and CurrentQubertAnimation != QubertAnimation.SMALLSLIDE:
			velocity += get_gravity() * delta
			if velocity.y > 0:
				if CurrentQubertAnimation == QubertAnimation.BIGJUMP or CurrentQubertAnimation == QubertAnimation.BIGREJUMP:
					CurrentQubertAnimation = QubertAnimation.BIGFALLING
					AnimationCoyoteEnable  = true
				else:
					CurrentQubertAnimation = QubertAnimation.FALLING

	if AnimationCoyoteEnable == true:
		if AnimationCoyoteTimer > CoyoteTimeDuration:
			AnimationCoyoteEnable = false
		else:
			AnimationCoyoteTimer += delta

	# Move Qubert to the right
	if CurrentQubertAnimation == QubertAnimation.BIGFALLING or CurrentQubertAnimation == QubertAnimation.BIGJUMP:
		velocity.x = 0.0
	elif CurrentQubertAnimation == QubertAnimation.SMALLSLIDE:
		velocity.x = SlidingMovementSpeed if GoingRight else -SlidingMovementSpeed
	else:
		velocity.x = MovementSpeed if GoingRight else -MovementSpeed

	# Handle jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		Jump()

	if Input.is_action_just_pressed("Jump") and CurrentQubertAnimation == QubertAnimation.BIGJUMP or CurrentQubertAnimation == QubertAnimation.BIGREJUMP:
		BigJump()

	if Input.is_action_just_pressed("Jump") and CurrentQubertAnimation == QubertAnimation.BIGFALLING and AnimationCoyoteEnable:
		BigJump()

	# Apply velocity
	move_and_slide()


func Jump() -> void:
	velocity.y = -JumpStrength
	CurrentQubertAnimation = QubertAnimation.JUMP


func BigJump() -> void:
	velocity.x = 0.0
	velocity.y = -BigJumpStrength
	CurrentQubertAnimation = QubertAnimation.BIGREJUMP


func HandleAnimation(delta: float) -> void:
	# Input
	if Input.is_action_pressed("ScaleQubertUp") and CurrentQubertAnimation != QubertAnimation.BIGJUMP or HasAlreadyScaledUpInAir:
		if not is_on_floor():
			HasAlreadyScaledUpInAir = true

		CurrentQubertAnimation = QubertAnimation.BIGJUMP

	if Input.is_action_pressed("ScaleQubertDown") and (CurrentQubertAnimation != QubertAnimation.SMALLSLIDE or HasAlreadyScaledDownInAir or CurrentQubertAnimation != QubertAnimation.BEGINSMALLSLIDE):
		if not is_on_floor():
			HasAlreadyScaledDownInAir = true

		CurrentQubertAnimation = QubertAnimation.BEGINSMALLSLIDE

	if CurrentQubertAnimation == QubertAnimation.IDLE:
		CurrentQubertSize = QubertSize.NORMAL
		if AnimPlayer.current_animation != "QubertAnimations/IDLE":
			AnimPlayer.play("QubertAnimations/IDLE")

	if CurrentQubertAnimation == QubertAnimation.BIGJUMP:
		CurrentQubertSize = QubertSize.LARGE
		if AnimPlayer.current_animation != "QubertAnimations/BIGJUMP":
			AnimPlayer.play("QubertAnimations/BIGJUMP")

	if CurrentQubertAnimation == QubertAnimation.BIGFALLING:
		CurrentQubertSize = QubertSize.LARGE
		if AnimPlayer.current_animation != "QubertAnimations/BIGFALLING":
			AnimPlayer.play("QubertAnimations/BIGFALLING")

		if is_on_floor():
			CurrentQubertAnimation = QubertAnimation.BIGSLAM

	if CurrentQubertAnimation == QubertAnimation.BIGSLAM:
		CurrentQubertSize = QubertSize.LARGE
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
			CurrentQubertAnimation = QubertAnimation.IDLE
		
		SlidingTimer += delta


func OnAnimationFinished(anim_name: StringName) -> void:
	if anim_name == "QubertAnimations/BIGJUMP":
		CurrentQubertAnimation = QubertAnimation.BIGFALLING
		AnimationCoyoteEnable  = true

	if anim_name == "QubertAnimations/BIGSLAM":
		CurrentQubertAnimation = QubertAnimation.IDLE
		pass

	if anim_name == "QubertAnimations/BEGINSMALLSLIDE":
		CurrentQubertAnimation = QubertAnimation.SMALLSLIDE
		pass

	if anim_name == "QubertAnimations/SMALLSLIDE":
		CurrentQubertAnimation = QubertAnimation.IDLE
		pass
		
	if anim_name == "QubertAnimations/JUMP":
		CurrentQubertAnimation = QubertAnimation.IDLE
		pass
