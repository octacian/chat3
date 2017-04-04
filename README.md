![Screenshot](.gh-screenshot.png)

Enhanced Chat [chat3]
=======================

Yes, chat3 seems a whole lot like a spinoff of chat2, however, it (mostly) isn't. It isn't that much unlike chat3, except for one thing: rather than cluttering the screen with a second chat window, chat3 just uses the default Minetest chat. Then it's entirely up to the player to configure the chat placement, size, and anything else on their client.

Messages are highlighted in a light blue to players who are within 12 blocks of the sender (configurable with `chat3.highlight_near` in `minetest.conf`). Messages in which the receiving player's name is mentioned are highlighted in a light green, as are PMs. Messages in which the first character is a `!` are highlighted in red to all players (also known as a shout).