extends CharacterBody2D

@export var speed = 20
@export var limit = 0.5
@export var endPoint: Marker2D

@onready var animations = $AnimationPlayer
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
	if area == $hitBox: return
	isDead = true
	animations.play("death")
	await animations.animation_finished
	queue_free()
