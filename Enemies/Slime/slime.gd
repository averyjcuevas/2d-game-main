extends CharacterBody2D

@export var speed = 20
@export var limit = 0.5
@export var endPoint: Marker2D

@onready var animations = $AnimationPlayer
@onready var poofSound = $Poof  # Reference to the Poof sound

var startPos
var endPos
var isDead: bool = false

func _ready():
	startPos = position
	endPos = endPoint.global_position

func changeDirection():
	var tempEnd = endPos
	endPos = startPos
	startPos = tempEnd

func updateVelocity():
	var moveDirection = endPos - position
	if moveDirection.length() < limit:
		changeDirection()
	
	velocity = moveDirection.normalized() * speed

func updateAnimation():
	if velocity.length() == 0:
		animations.stop()
	else:
		var direction = "Down"
		if velocity.x < 0: direction = "Left"
		elif velocity.x > 0: direction = "Right"
		elif velocity.y < 0: direction = "Up"
	
		animations.play("walk" + direction)

func _physics_process(delta):
	if isDead: return
	
	updateVelocity()
	move_and_slide()
	updateAnimation()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("Slime hit by:", area.name)  # Debugging: Check what hit the slime

	if not area.is_in_group("player_attack"): 
		print("Not a valid attack, ignoring")
		return  # Ignore everything except attacks

	print("Valid attack detected!")  # Debugging: Confirm attack is valid
	isDead = true
	animations.play("death")

	# Play the "poof" sound effect when the slime dies
	poofSound.play()

	await animations.animation_finished
	queue_free()
