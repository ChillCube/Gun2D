extends Sprite2D
class_name RotatingGun2D

@export var bullet_type : BulletResource;

func _ready() -> void:
	add_child(RotateToMouse.new())

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("mb_left"):
		shoot();

func shoot():
	var new_bullet = Projectile2D.new()
	new_bullet.bullet_resource = bullet_type
	new_bullet.move_using = 2  # DIRECTION mode
	new_bullet.direction = rad_to_deg(rotation)
	new_bullet.global_rotation = global_rotation
	get_tree().current_scene.add_child(new_bullet)
	new_bullet.global_position = global_position
