using Clutter;

public class Yamfe.Screen : Clutter.Actor {
	protected Script _script = new Script();
	private Clutter.Timeline _enter_anim = null;
	private Clutter.Timeline _leave_anim = null;

	public string ui_script { get; construct; }

	// This allows to do things before or after animations have ran.
	public signal void entered();
	public signal void left();

	public Screen(string script) {
		Object(ui_script: script);
	}

	/* Using the GObject style construction because we want to be able
	 * to build screens from a json file (json-glib). This will try to
	 * build an screen and set the ui-script property during construction.
	 */
	construct {
		uint merge_id = 0;

		try {
			merge_id = this._script.load_from_file(this.ui_script);
		} catch (Error err) {
			warning("%s\n", err.message);
		}

		if(merge_id == 0) {
			error("Could not load %s file properly.", this.ui_script);
		}

		// Pull the screen actor from the script. This should be the topmost
		// actor.
		Actor act = (Actor)_script.get_object("screen");
		if(act != null) {
			this.add_child(act);
		}

		// Fetch the enter/leave animations, if any.
		this._enter_anim = (Clutter.Timeline)_script.get_object("enter-anim");
		if(this._enter_anim != null) {
			this._enter_anim.completed.connect( () => {
				this.entered();
			});
		}

		this._leave_anim = (Clutter.Timeline)_script.get_object("leave-anim");
		if(this._leave_anim != null) {
			this._leave_anim.completed.connect( () => {
				this.left();
				this.hide();
			});
		}

		// Connect the signal handlers for this screen.		
		this._script.connect_signals(this);
		this.hide();
	}

	public virtual void enter() {
		this.show();

		if(this._enter_anim != null) {
			this._enter_anim.rewind();
			this._enter_anim.start();
		} else {
			this.entered();
		}
	}

	public virtual void leave() {
		if(this._leave_anim != null) {
			this._leave_anim.rewind();
			this._leave_anim.start();
		} else {
			this.left();
		}
	}
}
