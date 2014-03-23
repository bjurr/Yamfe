public interface Yamfe.Input : GLib.Object {
    [Flags]
    public enum InputType {
        UP,
        DOWN,
        LEFT,
        RIGHT,
        SELECT,
        CANCEL
    }

    public abstract void input_event(InputType input);
}