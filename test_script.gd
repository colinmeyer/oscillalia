extends SceneTree

func _init():
    print("Starting test...")
    
    # Check if files can be loaded
    var resources = [
        "res://scenes/Main.tscn",
        "res://scenes/ui/MainMenu.tscn",
        "res://scenes/level/Level.tscn",
        "res://scenes/player/Player.tscn"
    ]
    
    for res_path in resources:
        var resource = ResourceLoader.load(res_path)
        if resource:
            print("Successfully loaded: " + res_path)
        else:
            print("Failed to load: " + res_path)
    
    print("Test complete!")
    quit()