extends Node

enum { LOAD_SUCCESS, LOAD_ERROR_COULDNT_OPEN }

const SAVE_PATH = 'user://config.cfg'

var _config_file = ConfigFile.new()
var _settings = {
	'video': {
		'fullscreen': false,
	},
	'game': {
		'difficulty': Global.PRESET_BEGINNER
	}
}


func _ready():
	if load_settings() == LOAD_ERROR_COULDNT_OPEN:
		save_settings()
	OS.window_fullscreen = get_setting('video', 'fullscreen')


func save_settings():
	for section in _settings.keys():
		for key in _settings[section].keys():
			_config_file.set_value(section, key, _settings[section][key])
	_config_file.save(SAVE_PATH)


func load_settings():
	var error = _config_file.load(SAVE_PATH)
	if error != OK:
		print('Error loading settings. Code %s' % error)
		return LOAD_ERROR_COULDNT_OPEN
	
	for section in _settings.keys():
		for key in _settings[section].keys():
			var val = _config_file.get_value(section, key)
			_settings[section][key] = val
	return LOAD_SUCCESS


func set_setting(category, key, value):
	_settings[category][key] = value


func get_setting(category, key):
	return _settings[category][key]
