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

    public int up { get; set; default = 0xff52; }
    public string rom_path { get; set; default = "./roms/"; }
    public string mame_exec { get; set; default = "./bin/mame"; }
    public string mame_options { get; set; default = "./bin/mame"; }

    /**
     * Load up the json script, fetch the widgets and initialize the application.
     */
    private Main(string script_filename) {
		this._script = new Script();

		uint merge_id = 0;

        // The main json script contains the references for all the other screens.
		try {
			merge_id = this._script.load_from_file(script_filename);
		} catch (Error err) {
			warning("Could not load script file: %s\n", err.message);
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

    private void spawn_mame(string name) {
        message("Game selected: %s", name);

        // Spawn the actual Mame app.
        try {
            //string[] mame_args = {"./xmame-x11/xmame.x11", "-vidmod", "1", "-fullscreen", "-rp", "/home/arcade/roms", "-nocursor", name};
            string[] temp1 = this._mame_exec.split(" ");
            string[] temp2 = this._mame_options.split(" ");
            string[] mame_args = new string[temp1.length + temp2.length + 3];

            for(int i=0;i<temp1.length;i++) {
                mame_args[i] = temp1[i];
            }                 
            for(int i=0;i<temp2.length;i++) {
                mame_args[i+temp1.length] = temp2[i];
            }                

            mame_args[temp1.length+temp2.length] = "-rp";
            mame_args[temp1.length+temp2.length + 1] = this.rom_path;
            mame_args[temp1.length+temp2.length + 2] = name;
            string[] spawn_env = Environ.get ();
            string mame_stdout;
            string mame_stderr;
            int mame_status;
            
            Process.spawn_sync (null,
                                mame_args,
                                spawn_env,
                                SpawnFlags.SEARCH_PATH,
                                null,
                                out mame_stdout,
                                out mame_stderr,
                                out mame_status);

            // Print stdout/stderr for debugging purpose
            stdout.printf ("stdout:\n");
            stdout.puts (mame_stdout);

            stdout.printf ("stderr:\n");
            stdout.puts (mame_stderr);

            stdout.printf ("Mame exit code: %d\n", mame_status);

        } catch (SpawnError err) {
            warning("Spawn did not work: %s", err.message);
        }
    }

    /**
     * Everything is ready, let's start the application. This will fall in the Clutter main loop.
     */
    private int run() {
        this._current = this._splash;

        // Wire the screen enter/leave. This will control the flow for now, but
        // it will all make its way into an FSM eventually.
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

        (_select as Yamfe.SelectionScreen).selected.connect(spawn_mame);

        // Set the rom path to load in the selection screen.
        (_select as SelectionScreen).path = this.rom_path;

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
        //message("keyval: %u hardware: %u unicode: %u", event.keyval, event.hardware_keycode, event.unicode_value);

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
            case Clutter.Key.Control_L:
                this._input |= Yamfe.Input.InputType.SELECT;
                break;
			default:
				break;
		}
// CLUTTER_KEY_Shift_L = blue
// CLUTTER_KEY_Control_L = red
// CLUTTER_KEY_Alt_L = yellow
// CLUTTER_KEY_space = green

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
            case Clutter.Key.Control_L:
                this._input ^= Yamfe.Input.InputType.SELECT;
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
        const string CONFIG_FILE = "data/yamfe.ini";
        // First things first. Initialize the system.
        InitError err = Clutter.init(ref args);

        if(err != InitError.SUCCESS) {
            error("An error occured while initializing Clutter. Error code: %d\n", err);
        }

        // Load the configuration file
        KeyFile keyfile = new KeyFile();

        string main_script;

        try {
            keyfile.load_from_file(CONFIG_FILE, KeyFileFlags.NONE);
            main_script = keyfile.get_string ("YamfeGeneralSettings", "main_script");
        } catch (Error err) {
            error("Could not load configuration file: %s", err.message);
        }

        Main main = new Main(main_script);

        try {
            main.up = keyfile.get_integer ("YamfeKeyMap", "key_up");
            main.rom_path = keyfile.get_string ("YamfeGeneralSettings", "rom_path");
            message("rom path: %s", main.rom_path);
            main.mame_exec = keyfile.get_string ("YamfeGeneralSettings", "mame_exec");
            message("mame exec: %s", main.mame_exec);
            main.mame_options = keyfile.get_string ("YamfeGeneralSettings", "mame_options");
            message("mame options: %s", main.mame_options);
        } catch (Error err) {
            error("Error while fetching config: %s", err.message);
        }
        
        main.run();

        return 1;
    }
}

