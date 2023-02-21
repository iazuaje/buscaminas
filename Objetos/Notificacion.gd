extends Control

onready var animacion = $AnimationPlayer

func _ready():
	animacion.play("open-close")

func _on_LinkButton_pressed():
# warning-ignore:return_value_discarded
	OS.shell_open("https://github.com/iazuaje/buscaminas/releases")

func _on_Timer_timeout():
	animacion.play("close")


func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "close"):
		queue_free()
