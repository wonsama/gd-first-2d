extends Node

export (PackedScene) var mob_scene
var score

func _ready():
	# 여기에 randomize() 호출을 추가하여 
	# 게임이 실행될 때마다 난수 생성기가 다른 난수를 생성하도록 합니다.
	randomize()
	new_game()
	
func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()


func _on_ScoreTimer_timeout():
	score += 1

func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()


func _on_MobTimer_timeout():
	# Mob 장면의 새 인스턴스를 만듭니다.
	var mob = mob_scene.instance()

	# Path2D에서 임의의 위치를 선택합니다.
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	mob_spawn_location.offset = randi()
	#print(mob_spawn_location.offset)

	# 몹의 방향을 경로 방향에 수직으로 설정합니다.
	# ▶ 식으로 진행하므로 내부로 ▼ 꺽어주기 위해 + PI /2 한다 
	# 2 PI = 360 // 0.5 PI = 90 도
	var direction = mob_spawn_location.rotation + PI / 2
	
	# 몹의 위치를 임의의 위치로 설정합니다.
	mob.position = mob_spawn_location.position

	# 방향에 임의성을 추가합니다.
	# PI / 4 = 45도 ( - 45 ... + 45 ) 
	direction += rand_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# 몹의 속도를 선택합니다.
	# X 축이동 속도 지정
	# 회전한 만큼 돌려서 해당 방향으로 이동하도록 처리
	var velocity = Vector2(rand_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	#mob.linear_velocity = velocity

	# 메인 장면에 추가하여 몹을 생성합니다.
	add_child(mob)
