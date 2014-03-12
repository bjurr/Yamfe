public interface Yamfe.Input : GLib.Object {
    [Flags]
    public enum InputType {
        UP,
        DOWN,
        LEFT,
        RIGHT,
        BUTTON_A,
        BUTTON_B,
        BUTTON_C,
        BUTTON_D,
        BUTTON_1
    }

    public abstract void input_event(InputType input);
}