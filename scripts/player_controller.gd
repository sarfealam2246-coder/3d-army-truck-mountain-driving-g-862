extends CharacterBody3D

@export var max_speed: float = 32.1
@export var steer_sensitivity: float = 2.6
var speed_multiplier: float = 1.0
var touch_steer: float = 0.0
var throttle: float = 0.0

func _ready() -> void:
	var bridge = get_node_or_null("/root/Main/AppsSupabaseBridge")
	if bridge:
		bridge.remote_config_loaded.connect(_on_remote_config)

func _on_remote_config(cfg: Dictionary) -> void:
	speed_multiplier = float(cfg.get("speed_multiplier", 1.0))

func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		touch_steer = clamp(touch_steer + event.relative.x * 0.008, -1.0, 1.0)
		throttle = 1.0

func _physics_process(delta: float) -> void:
	var steer := Input.get_axis("ui_right", "ui_left") - touch_steer
	rotate_y(steer * steer_sensitivity * delta)
	var forward := -transform.basis.z
	var target_vel := forward * (max_speed * speed_multiplier * max(throttle, Input.get_action_strength("ui_up")))
	velocity = velocity.lerp(target_vel, delta * 3.5)
	move_and_slide()
