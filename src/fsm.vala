class Fsm : GLib.Object {
	public bool load(string filename) {
		return true;
	}

	public bool trigger(string event) {
		return true;
	}
}

enum StateFlags {
	NONE = 0,
	DEFAULT = 0x01,
	HISTORY = 0x02,
	NINJA = 0x04
}

enum EventFlags {
	NONE = 0,
	DEFAULT = 0x01,
	HISTORY = 0x02,
	NINJA = 0x04
}

struct State {
	public string name;
	public StateFlags flags;
}

struct Event {
	public string name;
	public string action_name;
	public string condition_name;
	public string action_ptr;
	public string condition_ptr;
	public string args;
	public EventFlags flags;
}