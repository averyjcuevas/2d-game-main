extends CharacterBody2D

signal healthChanged

@export var speed: int = 35
@onready var animations = $Sprite2D/AnimationPlayer
@onready var weapon = $weapons

@export var maxHealth = 10
@onready var currentHealth: int = maxHealth

@export var inventory: Inventory

# Add an AudioStreamPlayer for the sword slash sound
@onready var swordSlashAudio = $SwordSlash 

var lastAnimDirection: String = "Down"
var isAttacking: bool = false

# Handle player movement and input
func handleInput():
	var moveDirection = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = moveDirection * speed
	
	if Input.is_action_just_pressed("attack"):
		attack()

# Perform the attack animation, play the sound, and handle weapon visibility
func attack():
	animations.play("attack" + lastAnimDirection)
	isAttacking = true
	weapon.visible = true
	weapon.enable()  # Enable sword hitbox when attacking

	# Play the sword slash sound (MP3 file)
	swordSlashAudio.play()  # This plays the MP3 sound when the player attacks

	await animations.animation_finished
	weapon.disable()  # Disable sword hitbox after the attack
	weapon.visible = false
	isAttacking = false

# Update the player's animation based on movement
func updateAnimation():
	if isAttacking: return
	
	if velocity.length() == 0:
		animations.stop()
	else:
		var direction = "Down"
		if velocity.x < 0: direction = "Left"
		elif velocity.x > 0: direction = "Right"
		elif velocity.y < 0: direction = "Up"
	
		animations.play("walk" + direction)
		lastAnimDirection = direction

# Decrease the player's health when colliding with enemy hitboxes
func _on_hurtbox_area_entered(area):
	print("Collided with: " + area.name)  # Debugging output
	if area.is_in_group("enemy_hitbox"):  # Check if the area is an enemy hitbox
		take_damage(1)  # Apply damage (adjust value as needed)

# Function to reduce health and handle player death
func take_damage(amount):
	currentHealth -= amount
	if currentHealth <= 0:
		currentHealth = 0  # Handle player death (e.g., respawn or game over)
		print("Player has died!")
		# Optionally, trigger a death screen or respawn logic here.
		# For example:
		# get_tree().change_scene_to_file("res://Levels/death_screen.tscn")
	healthChanged.emit(currentHealth)  # Update health UI or other systems

# Main update loop for movement and animations
func _physics_process(delta):
	handleInput()
	move_and_slide()
	updateAnimation()
