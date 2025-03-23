extends CharacterBody2D

signal healthChanged

@export var speed: int = 35
@onready var animations = $Sprite2D/AnimationPlayer

@onready var weapon = $weapons

@export var maxHealth = 10
@onready var currentHealth: int = maxHealth

@export var inventory: Inventory

var lastAnimDirection: String = "Down"
var isAttacking: bool = false

func handleInput():
	var moveDirection = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = moveDirection * speed
	
	if Input.is_action_just_pressed("attack"):
		attack()
		
func attack():
	animations.play("attack" + lastAnimDirection)
	isAttacking = true
	weapon.visible = true
	await animations.animation_finished
	weapon.visible = false
	isAttacking = false
		
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


func handleCollision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		print_debug(collider.name)

func _on_hurt_box_area_entered(area):
	if area.has_method("collect"):
		area.collect(inventory)
	if area.name == "HitBox":
		currentHealth -= 1
		if currentHealth < 0:
			currentHealth = maxHealth
		healthChanged.emit(currentHealth)

func _physics_process(delta):
		handleInput()
		move_and_slide()
		handleCollision()
		updateAnimation()
