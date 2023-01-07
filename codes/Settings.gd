extends Node

export var Background : bool = true setget set_background_status
export var Sounds : bool = true setget set_sound_status

signal sound_stats_changed(new_stats)
signal background_stats_changed(new_stats)

func set_background_status(new_stats := true):
	Background = new_stats
	emit_signal("background_stats_changed", new_stats)

func set_sound_status(new_stats := true):
	Sounds = new_stats
	emit_signal("sound_stats_changed", new_stats)
