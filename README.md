![Screenshot](.gh-screenshot.png)

Enhanced Chat [chat3]
=======================
**Notice:** The client experience with chat3 can be improved by using Minetest 0.4.16 on the server. In order to use chat3 at its full potential, you need a version of Minetest that includes [this commit](https://github.com/minetest/minetest/commit/1ef9eee31133a3001ed0c642df5cbe54169850de) (April 27th, 2017).

Yes, chat3 seems a whole lot like a spinoff of chat2, however, it (mostly) isn't. It isn't that much unlike chat3, except for one thing: rather than cluttering the screen with a second chat window, chat3 just uses the default Minetest chat. Then it's entirely up to the player to configure the chat placement, size, and anything else on their client.

Messages are highlighted in a light blue to players who are within 12 blocks of the sender (configurable with `chat3.highlight_near` in `minetest.conf`, if set to `0` positional highlighting is ignored). Messages in which the receiving player's name is mentioned are highlighted in a light green, as are PMs. Messages in which the first character is a `!` are highlighted in red to all players (also known as a shout).

If the server is using Minetest 0.4.16, which has the ability to properly retreive the protocol version of the client without requiring a debug build, chat3 will automatically adjust its message handling to work with older clients as well. This means that clients before 0.4.16 will not see chat duplication on their side, and colour codes will not be sent to clients that do not support them.
