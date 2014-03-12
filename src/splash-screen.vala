using Clutter;

class Yamfe.SplashScreen : Screen {
    public int timeout { get; set; default = 5000; }

	public SplashScreen(string script) {
    	base(script);
	}

    public override void enter() {
        var time = new TimeoutSource(this.timeout);
        time.set_callback( () => {
            this.leave();
            return false;
        });

        time.attach(null);

        base.enter();
    }

    public override void leave() {
        base.leave();
    }
}
