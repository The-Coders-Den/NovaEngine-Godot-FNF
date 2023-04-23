extends Stage

@onready var tank_ground:AnimatedSprite2D = $PB/PL6/tank_ground

@onready var boppers:Array = [
	$PB2/PL8/bopper1,
	$PB2/PL9/bopper2,
	$PB2/PL10/bopper3,
	$PB2/PL10/bopper4,
	$PB2/PL10/bopper5,
	$PB2/PL11/boppeer6,
	$PB/PL6/tank_watch_tower,
]

var tank_angle:float = randi_range(-90, 45)
var tank_speed:float = randf_range(5, 7)
const TANK_X:float = 400

func _ready():
	Conductor.beat_hit.connect(beat_hit)
	$PB/PL5/smoke_right.play("SmokeRight instance 1")
	$PB/PL5/smoke_left.play("SmokeBlurLeft instance 1")

func _process(delta: float) -> void:
	tank_angle += delta * tank_speed
	tank_ground.rotation_degrees = tank_angle - 90 + 15
	tank_ground.position = Vector2(TANK_X + cos(deg_to_rad(tank_angle + 180)) * 1500,
			1300 + sin(deg_to_rad(tank_angle + 180)) * 1100)

func beat_hit(beat:int):
	for bopper in boppers:
		bopper.play("bop")
