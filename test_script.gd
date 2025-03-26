extends SceneTree

func _init():
    print("Starting test...")
    
    # Check if core scene files can be loaded
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
    
    # Verify directory structure
    var directories = [
        "res://assets/audio/music",
        "res://assets/audio/sfx",
        "res://resources/levels",
        "res://scenes/ui",
        "res://scenes/level",
        "res://scenes/player",
        "res://scenes/npcs"
    ]
    
    var dir = DirAccess.open("res://")
    for directory in directories:
        if dir.dir_exists(directory):
            print("Directory exists: " + directory)
        else:
            print("Warning: Directory missing: " + directory)
    
    # Verify presence of level data
    var level_data = ResourceLoader.load("res://resources/levels/level_1.tres")
    if level_data:
        print("Level data found and loaded")
    else:
        print("Warning: Could not load level data")
    
    print("Test complete!")
    quit()