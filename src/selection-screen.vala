using Clutter;

class Yamfe.SelectionScreen : Screen ,Input {
	private Actor _square = null;

	public SelectionScreen(string script) {
    	base(script);
	}

	public void input_event(Input.InputType input) {
		switch(input) {
			case Input.InputType.UP:
				this._square.move_by(0,-10);
				break;

			case Input.InputType.DOWN:
				this._square.move_by(0,10);
				break;

			case Input.InputType.LEFT:
				this._square.move_by(-10,0);
				break;

			case Input.InputType.RIGHT:
				this._square.move_by(10,0);
				break;

			default:
				break;
		}
    }

    construct {
    	this._square = (Clutter.Actor)_script.get_object("sss");
    }
}
