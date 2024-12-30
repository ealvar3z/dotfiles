#!/usr/bin/env python3

import curses
import time

def coffee_break(stdscr):

    curses.curs_set(0)
    stdscr.nodelay(1)
    stdscr.timeout(10)

    coffee_frames = [
        [
            "   ( (",
            "    ) )",
            "  ......",
            "  \\ ~~~ /",
            "   )___(",
            "  (_____)",
        ],
        [
            "   ) )",
            "    ( (",
            "  ......",
            "  \\ ~~~ /",
            "   )___(",
            "  (_____)",
        ],
        [
            "   ( (",
            "  ......",
            "     ) )",
            "  \\ ~~~ /",
            "   )___(",
            "  (_____)",
        ]
    ]

    frame_count = len(coffee_frames)
    frame_index = 0
    h, w, = stdscr.getmaxyx()
    msg = "brb: brewing coffee"
    coffee_x = (w // 2) - 8
    coffee_y = (h // 2) - 3
    msg_x = (w // 2) - (len(msg) // 2)
    msg_y = coffee_y + 8

    while True:
        stdscr.clear()

        for i, line in enumerate(coffee_frames[frame_index]):
            stdscr.addstr(coffee_y + i, coffee_x, line)

        stdscr.addstr(msg_y, msg_x, msg)
        stdscr.refresh()

        key = stdscr.getch()
        if key == ord('q'):
            break

        frame_index = (frame_index + 1) % frame_count
        time.sleep(0.2)



def main():
    curses.wrapper(coffee_break)

if __name__ == "__main__":
    main()
