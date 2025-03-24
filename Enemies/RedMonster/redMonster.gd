extends CharacterBody2D

@export var speed = 20
@export var limit = 0.5
@export var endPoint: Marker2D

@onready var animations = $AnimationPlayer
@onready var poofSound = $Poof  # Reference to the Poof sound effect

var startPos
var endPos
var isDead: bool = false

# Called when the node is ready
func _ready():
	startPos = position
	endPos = endPoint.global_position

# Change direction when the end point is reached
func changeDirection():
	var tempEnd = endPos
	endPos = startPos
	startPos = tempEnd

# Update the velocity to move the character towards the end point
func updateVelocity():
	var moveDirection = endPos - position
	if moveDirection.length() < limit:
		changeDirection()
	
	velocity = moveDirection.normalized() * speed

# Update animation based on the movement velocity
func updateAnimation():
	if velocity.length() == 0:
		animations.stop()
	else:
		var direction = "Down"
		if velocity.x < 0: direction = "Left"
		elif velocity.x > 0: direction = "Right"
		elif velocity.y < 0: direction = "Up"
	
		animations.play("walk" + direction)

# Main physics process loop
func _physics_process(delta):
	if isDead: return
	
	updateVelocity()
	move_and_slide()
	updateAnimation()

# Handle when the monster is hit by an attack
func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("RedMonster hit by:", area.name)  # Debugging: Check what hit the monster

	if not area.is_in_group("player_attack"): 
		print("Not a valid attack, ignoring")
		return  # Ignore everything except attacks

	print("Valid attack detected!")  # Debugging: Confirm attack is valid
	isDead = true
	animations.play("death")

	# Debugging: Confirm that sound will be played
	print("Playing Poof sound")
	poofSound.play()  # Play the "poof" sound effect when the RedMonster dies

	await animations.animation_finished
	queue_free()
