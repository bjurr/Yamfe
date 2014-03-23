using Clutter;

class Yamfe.SelectionScreen : Screen ,Input {
	private ScrollActor _games_list = null;
	private int _current_selection = 0;

	public signal void selected(string game_name);

	public string path { get; set; default = "./roms/"; }

	public SelectionScreen(string script) {
    	base(script);
	}

	public override void enter() {
        // Load the folder and display the games list. Eventually, we'll want to do this
        // only once, and probably cache it.
        try {
        	var directory = File.new_for_path (this.path);
	        var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);

	        FileInfo file_info;
	        while ((file_info = enumerator.next_file ()) != null) {
    			Actor entry = new Actor();
    			entry.width = 600;
    			entry.background_color = Clutter.Color.get_static(Clutter.StaticColor.BLUE);

			string str = file_info.get_name();
			int len = str.last_index_of(".zip");
			string asd = str[0:len];
			message("Name is: %s", asd);
    			Text t = new Text.full("Arial 20", asd, Clutter.Color.get_static(Clutter.StaticColor.WHITE));
    			entry.add_child(t);
    			this._games_list.add_child(entry);
	        }
	    } catch (Error e) {
	        error ("Error: %s", e.message);
	    }

	    // Initialize the list
	    var actor = this._games_list.get_first_child();
    	actor.background_color = Clutter.Color.get_static(Clutter.StaticColor.GREEN);
    	this._current_selection = 0;
    	float x, y;
    	actor.get_position(out x, out y);
    	Point p = Point.alloc();
    	p.init(x,(this._games_list.height/-2.0f) + y);
	    this._games_list.scroll_to_point(p);

        base.enter();
    }

    private void previous_item() {
    	if(this._current_selection > 0) {
    		var actor = this._games_list.get_child_at_index(this._current_selection);
    		actor.background_color = Clutter.Color.get_static(Clutter.StaticColor.BLUE);
    		this._current_selection--;
    		actor = this._games_list.get_child_at_index(this._current_selection);
    		actor.background_color = Clutter.Color.get_static(Clutter.StaticColor.GREEN);

    		float x;
    		float y;
    		actor.get_position(out x, out y);
    		Point p = Point.alloc();
    		p.init(x,(this._games_list.height/-2.0f) + y);
    		this._games_list.scroll_to_point(p);
    	}
    }

    private void next_item() {
    	if(this._current_selection < this._games_list.get_n_children() - 1) {
    		var actor = this._games_list.get_child_at_index(this._current_selection);
    		actor.background_color = Clutter.Color.get_static(Clutter.StaticColor.BLUE);
    		this._current_selection++;
    		actor = this._games_list.get_child_at_index(this._current_selection);
    		actor.background_color = Clutter.Color.get_static(Clutter.StaticColor.GREEN);

    		float x;
    		float y;
    		actor.get_position(out x, out y);
    		Point p = Point.alloc();
    		p.init(x,(this._games_list.height/-2.0f) + y);
    		this._games_list.scroll_to_point(p);
    	}
    }

	public void input_event(Input.InputType input) {
		switch(input) {
			case Input.InputType.UP:
				this.previous_item();
				break;

			case Input.InputType.DOWN:
				this.next_item();
				break;

			case Input.InputType.LEFT:
				break;

			case Input.InputType.RIGHT:
				break;

			case Input.InputType.SELECT:
				Actor container = this._games_list.get_child_at_index(this._current_selection);
				Text name = (Clutter.Text)container.get_first_child();
				this.selected(name.get_text());
				break;

			default:
				break;
		}
    }

    construct {
    	this._games_list = (Clutter.ScrollActor)_script.get_object("games-list");
    }
}
