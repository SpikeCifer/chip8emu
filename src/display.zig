const std = @import("std");
const cx11 = @cImport(@cInclude("X11/Xlib.h"));

const POSY = 500;
const POSX = 500;
const WIDTH = 500;
const HEIGHT = 500;
const BORDER = 20;

pub fn create_window() void {
    const Display = cx11.XOpenDisplay(null).?; // If the returned pointer is null, exit
    defer _ = cx11.XCloseDisplay(Display);

    const Screen = cx11.DefaultScreen(Display);
    const Window = cx11.XCreateSimpleWindow(Display, cx11.RootWindow(Display, Screen), POSX, POSY, WIDTH, HEIGHT, BORDER, cx11.BlackPixel(Display, Screen), cx11.WhitePixel(Display, Screen));
    _ = cx11.XMapWindow(Display, Window);

    display_loop: while (true) {
        var Event: cx11.XEvent = undefined;
        _ = cx11.XNextEvent(Display, &Event);

        switch (Event.type) {
            cx11.Expose => {
                _ = cx11.XFillRectangle(Display, Window, cx11.DefaultGC(Display, Screen), 20, 20, 10, 10);
            },
            else => continue :display_loop,
        }
    }
}

pub fn main() void {
    create_window();
}
