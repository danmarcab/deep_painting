#Studio.create_painting("my_painting")
#Studio.add_painting_content("my_painting", Application.app_dir(:studio, "priv") <> "/content.png")
#Studio.add_painting_style("my_painting", Application.app_dir(:studio, "priv") <> "/style.jpg")
#Studio.add_painting_settings("my_painting", Studio.Painting.Settings.new)
#
#Studio.start_painting("my_painting")
IO.puts "loading env vars"
System.put_env("GALLERY_HOST", "localhost")
System.put_env("GALLERY_PORT", "4000")
System.put_env("STUDIO_HOST", "localhost")
System.put_env("STUDIO_PORT", "4001")
System.put_env("PYCASSO_PATH", "/Users/daniel/Projects/PFC/codigo/playaround/keras-tutorial/venv/bin/python /Users/daniel/Projects/PFC/codigo/deep_painting/deep_painting.py")
IO.puts "env vars loaded"
