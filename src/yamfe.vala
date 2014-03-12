/*
 * Yamfe - Yet Another Mame Front End
 * 
 * Author: Dominique Bureau <dbureau@gmail.com>
 * March 2014
 *
 * Yamfe is a simple launcher for Mame (or any other similar app)
 * written in Vala and using the CLutter UI toolkit.
 */

using Clutter;
using GLib;

internal class Yamfe.Main : GLib.Object {
    private Screen _screen = null;
    private Screen _splash = null;
    private Screen _select = null;
    private Screen _current = null;
    private Clutter.Script _script = null;
    private Clutter.Stage _stage = null;
    private Input.InputType _input = 0;

    /**
     * Load up the json script, fetch the widgets and initialize the application.
     */
    private Main(string script_filename) {
		this._script = new Script();

		uint merge_id = 0;

        // The main json script contains the references for all the other screens.
		try {
			merge_id = this._script.load_from_file(script_filename);
		} catch (Error exr) {
			stdout.printf("Error: %s\n", exr.message);
		}

		if(merge_id == 0) {
			error("Something went wrong.");
		}

        // Keep a handle to the stage. This might come in handy.
		this._stage = (Stage)this._script.get_object("stage");
		this._stage.set_title("Yamfe!");

        // For now, keep references to the built screens. I will make this a bit
        // more generic eventually.
        this._screen = (Yamfe.Screen)this._script.get_object("test_screen");
        this._splash = (Yamfe.Screen)this._script.get_object("splash_screen");
        this._select = (Yamfe.Screen)this._script.get_object("selection_screen");

        this._stage.key_press_event.connect(key_press_handler);
        this._stage.key_release_event.connect(key_release_handler);

        // If there are other signals defined, try to connect them.
        this._script.connect_signals(this._stage);
    }

    /**
     * Everything is ready, let's start the application. This will fall in the Clutter main loop.
     */
    private int run() {
        this._current = this._splash;

        this._splash.entered.connect(() => {
            message("Entered splash screen");
        });

        this._splash.left.connect(() => {
            message("Left splash screen");
            message("Going to selection-screen");
            this._current = this._select;
            this._select.enter();
        });

        this._select.entered.connect(() => {
            message("Entered selection screen");
        });

        this._select.left.connect(() => {
            message("Left selection screen");
        });

        this._stage.show();
        this._splash.enter();

        Clutter.main();
        return 1;
    }

    /**
     * Keyboard handler. I use the default Mame key mappings for now, and translate those
     * into more generic UP, DOWN, LEFT, RIGHT, A, B, C, D, 1-START codes. This will allow
     * me to easily remap the keys later down the road.
     */
    private bool key_press_handler(Clutter.Actor actor, Clutter.KeyEvent event) {
		switch(event.keyval) {
			case Clutter.Key.Escape:
				Clutter.main_quit();
				break;
            case Clutter.Key.Up:
                this._input |= Yamfe.Input.InputType.UP;
                break;
            case Clutter.Key.Down:
                this._input |= Yamfe.Input.InputType.DOWN;
                break;
            case Clutter.Key.Left:
                this._input |= Yamfe.Input.InputType.LEFT;
                break;
            case Clutter.Key.Right:
                this._input |= Yamfe.Input.InputType.RIGHT;
                break;
			default:
				break;
		}

        // Send the event only to screens that implement the Yamfe.Input interface.
        if(this._current is Yamfe.Input) {
            (this._current as Yamfe.Input).input_event(this._input);
        }
		return false;
	}

    private bool key_release_handler(Clutter.Actor actor, Clutter.KeyEvent event) {
        switch(event.keyval) {
            case Clutter.Key.Up:
                this._input ^= Yamfe.Input.InputType.UP;
                break;
            case Clutter.Key.Down:
                this._input ^= Yamfe.Input.InputType.DOWN;
                break;
            case Clutter.Key.Left:
                this._input ^= Yamfe.Input.InputType.LEFT;
                break;
            case Clutter.Key.Right:
                this._input ^= Yamfe.Input.InputType.RIGHT;
                break;
            default:
                break;
        }

        // Send the event only to screens that implement the Yamfe.Input interface.
        if(this._current is Yamfe.Input) {
            (this._current as Yamfe.Input).input_event(this._input);
        }
        return false;
    }

    private static int main(string[] args) {
        const string MAIN_SCRIPT = "data/yamfe.json";
        // First things first. Initialize the system.
        InitError err = Clutter.init(ref args);

        if(err != InitError.SUCCESS) {
            error("An error occured while initializing Clutter. Error code: %d\n", err);
        }

        Main main = new Main(MAIN_SCRIPT);

        main.run();

        return 1;
    }
}

