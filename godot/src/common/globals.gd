extends Node


const MUSIC_VOLUME=-6
const GAME_SCENE_PATH = "res://src/main.tscn"
const MAP_SCENE_PATH = "res://src/map/map_screen.tscn"

const TILES_PER_ROOM = 19 
const TILE_SIZE = 32
const MAP_CELL_SIZE = 64
const LANDMARK_SIZE = 96
const HINT_SIZE = 32
const AUTOMATA_ITERS=100
const FOLLIAGE_RATIO=.45
const TILE_RATIO=[.2,.5]


var master_volume:float = 100
var music_volume:float = 100
var sfx_volume:float = 100

const GameDataPath = "user://conf.cfg"
var config:ConfigFile

var debug_build := false
var in_game:=false
var map_mode:= Types.MapMode.Rooms:
	set(value):
		if value != map_mode:
			map_mode = value
			Events.map_mode_changed.emit()

var last_dungeon:Dungeon
var dungeon: Dungeon
var current_room: Room
var player: Player
var current_level:=0
var current_hints:=0
var last_landmarks:={}
var done_tutorial_steps=[]
@export var levels:Array[BlockGenerator]
@export var debug_skip_eval:bool = false

var music_on:=true:
	set(v):
		music_on=v
		Logger.info("music %s" % [music_on])
		var sfx_index= AudioServer.get_bus_index("Music")
		AudioServer.set_bus_volume_db(sfx_index, -9 if music_on else -100)
	

var sound_on:=true:
	set(v):
		sound_on = v
		Logger.info("sound %s" % [sound_on])
		var sfx_index= AudioServer.get_bus_index("Sound")
		AudioServer.set_bus_volume_db(sfx_index, 0 if sound_on else -100)
	

@onready var menu_music: AudioStreamPlayer = $menu_music
@onready var explore_music: AudioStreamPlayer = $explore_music
@onready var fighter_music: AudioStreamPlayer = $fighter_music
@onready var puzzle_music: AudioStreamPlayer = $puzzle_music

func _ready():
	_init_logger()

	Logger.info("Starting menu music")
	fade_in_music(menu_music)
	
func next_level():
	current_level += 1
	last_dungeon=null
	if current_level<levels.size():
		start_game()	
	else:
		do_end()
func retry_level():
	start_game()
	
func do_game_over():
	Logger.info("Game over")
	get_tree().quit()

func do_end():
	Logger.info("Finished game")
	get_tree().quit()

func start_game():
	in_game=true
	last_landmarks={}	
	current_hints=0
	
	fade_music(puzzle_music,1)
	fade_music(menu_music,1)
	await get_tree().create_timer(.1).timeout
	SceneManager.change_scene(GAME_SCENE_PATH)
	fade_in_music(explore_music)
	play_music(fighter_music,-60)
	
	

func go_to_map():
	fade_music(explore_music,.5)
	fade_music(fighter_music,.5)	
	SceneManager.change_scene(MAP_SCENE_PATH)
	fade_in_music(puzzle_music)
	

func _init_logger():
	Logger.set_logger_level(Logger.LOG_LEVEL_INFO)
	Logger.set_logger_format(Logger.LOG_FORMAT_MORE)
	var console_appender:Appender = Logger.add_appender(ConsoleAppender.new())
	console_appender.logger_format=Logger.LOG_FORMAT_FULL
	console_appender.logger_level = Logger.LOG_LEVEL_INFO
	var file_appender:Appender = Logger.add_appender(FileAppender.new("res://debug.log"))
	file_appender.logger_format=Logger.LOG_FORMAT_FULL
	file_appender.logger_level = Logger.LOG_LEVEL_DEBUG
	Logger.info("Logger initialized.")

func cross_fade_dungeon_music():
	cross_fade_music(explore_music, fighter_music)
#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("ui_cancel"):
		#cross_fade_music(explore_music, fighter_music)
		#Logger.info("cross fade")
func play_music(node:AudioStreamPlayer, volume :=MUSIC_VOLUME):
	if not node.playing:
		node.volume_db = volume
		node.play()
	
func cross_fade_music(from:AudioStreamPlayer, to:AudioStreamPlayer, duration:=1):
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(from,"volume_db",-60 , duration)
	tween.parallel().tween_property(to,"volume_db",MUSIC_VOLUME, duration).set_ease(Tween.EASE_OUT)
	
func fade_in_music(node:AudioStreamPlayer, duration := 1.0):
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	node.volume_db=-20
	node.play()
	tween.tween_property(node,"volume_db",0 , duration)
	

func fade_music(node:AudioStreamPlayer, duration := 1.0):
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node,"volume_db",-20 , duration)
	await tween.finished
	node.stop()
	
