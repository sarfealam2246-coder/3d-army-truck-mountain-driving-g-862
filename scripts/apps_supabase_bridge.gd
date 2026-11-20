extends Node
class_name AppsSupabaseBridge

# Injected strictly from Apps Supabase (isolated from Studio Supabase)
const SUPABASE_URL := "https://YOUR-APPS-PROJECT.supabase.co"
const SUPABASE_ANON_KEY := "YOUR_APPS_SUPABASE_ANON_KEY"
const APP_SLUG := "3d-army-truck-mountain-driving-g"

signal remote_config_loaded(config: Dictionary)

var http: HTTPRequest

func _ready() -> void:
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	fetch_live_config()

func fetch_live_config() -> void:
	if not SUPABASE_URL.begins_with("https://"):
		return
	var url := SUPABASE_URL + "/rest/v1/apps_config?app_slug=eq." + APP_SLUG + "&select=*"
	var headers := PackedStringArray([
		"apikey: " + SUPABASE_ANON_KEY,
		"Authorization: Bearer " + SUPABASE_ANON_KEY
	])
	http.request(url, headers)

func _on_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		return
	var parsed = JSON.parse_string(body.get_string_from_utf8())
	if typeof(parsed) == TYPE_ARRAY and parsed.size() > 0:
		emit_signal("remote_config_loaded", parsed[0])
