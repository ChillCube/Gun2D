extends Sprite2D
class_name RotatingGun2D

@export var bullet_type: BulletResource
@export var spawn_margin: float = 2.0

func _ready() -> void:
	add_child(RotateToMouse.new())

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("mb_left"):
		shoot()

func shoot() -> void:
	var shoot_dir := Vector2(cos(rotation), sin(rotation))
	var offset := _find_shape_clearance(shoot_dir) + spawn_margin

	var new_bullet := Projectile2D.new()
	new_bullet.bullet_resource = bullet_type
	new_bullet.move_using = 2  # DIRECTION mode
	new_bullet.direction = rad_to_deg(rotation)
	new_bullet.global_rotation = global_rotation
	get_tree().current_scene.add_child(new_bullet)
	new_bullet.global_position = global_position + shoot_dir * offset

func _find_shape_clearance(shoot_dir: Vector2) -> float:
	var max_reach := 0.0
	for node in get_children():
		max_reach = maxf(max_reach, _node_reach(node, shoot_dir))
	var parent := get_parent()
	if parent:
		for node in parent.get_children():
			if node != self:
				max_reach = maxf(max_reach, _node_reach(node, shoot_dir))
	return max_reach

func _node_reach(node: Node, shoot_dir: Vector2) -> float:
	if node is CollisionShape2D:
		return _shape_reach(node as CollisionShape2D, shoot_dir)
	if node is CollisionPolygon2D:
		return _polygon_reach(node as CollisionPolygon2D, shoot_dir)
	return 0.0

func _shape_reach(cs: CollisionShape2D, shoot_dir: Vector2) -> float:
	if cs.shape == null or cs.disabled:
		return 0.0
	var xform := cs.global_transform
	var shape := cs.shape
	if shape is CircleShape2D:
		var proj := (xform.origin - global_position).dot(shoot_dir)
		return maxf(0.0, proj + (shape as CircleShape2D).radius)
	if shape is CapsuleShape2D:
		var cap := shape as CapsuleShape2D
		var half_cyl := cap.height * 0.5 - cap.radius
		var t := (xform * Vector2(0.0, -half_cyl) - global_position).dot(shoot_dir) + cap.radius
		var b := (xform * Vector2(0.0,  half_cyl) - global_position).dot(shoot_dir) + cap.radius
		return maxf(0.0, maxf(t, b))
	var pts: Array[Vector2] = []
	if shape is RectangleShape2D:
		var h := (shape as RectangleShape2D).size * 0.5
		pts = [xform * Vector2(-h.x, -h.y), xform * Vector2(h.x, -h.y),
			   xform * Vector2(h.x, h.y),   xform * Vector2(-h.x, h.y)]
	elif shape is ConvexPolygonShape2D:
		for pt in (shape as ConvexPolygonShape2D).points:
			pts.append(xform * pt)
	elif shape is ConcavePolygonShape2D:
		for pt in (shape as ConcavePolygonShape2D).segments:
			pts.append(xform * pt)
	var max_proj := 0.0
	for wp in pts:
		max_proj = maxf(max_proj, (wp - global_position).dot(shoot_dir))
	return max_proj

func _polygon_reach(cp: CollisionPolygon2D, shoot_dir: Vector2) -> float:
	if cp.disabled or cp.polygon.is_empty():
		return 0.0
	var xform := cp.global_transform
	var max_proj := 0.0
	for pt in cp.polygon:
		max_proj = maxf(max_proj, (xform * pt - global_position).dot(shoot_dir))
	return max_proj
