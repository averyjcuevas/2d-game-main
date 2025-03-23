extends Area2D

@onready var shape = $CollisionShape2D

func _ready():
	add_to_group("player_attack")  # Ensure sword belongs to the attack group
	connect("area_entered", Callable(self, "_on_area_entered"))  # Detect hits
	shape.disabled = true  # Disable the sword's hitbox initially

func enable():
	shape.disabled = false  # Enable sword hitbox during attack

func disable():
	shape.disabled = true  # Disable sword hitbox after attack is over

func _on_area_entered(area: Area2D):
	print("Sword hit:", area.name)  # Debugging: See what the sword hits
