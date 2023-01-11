extends Control

export(String, FILE, "*.tscn") var next_scene_path

onready var animation = $AnimationPlayer

func _ready():
	animation.play_backwards("fade")

func transicionar(next_scene := next_scene_path) -> void:
	animation.play("fade")
	yield(animation, "animation_finished")
	
# warning-ignore:return_value_discarded
	get_tree().change_scene(next_scene)
