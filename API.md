Chat3 API
=========

Main API
--------

`chat3.colorize(name, color, msg)`

* Checks protocol of `name` and if recent enough returns the colourized `msg`
* This does not send the message to the player, but just returns the message.
* `name`: Name of player to whom the colorized message is to be sent
* `color`: Hex-code or color name (string)
* `msg`: Message to colorize

`chat3.send(name, msg, prefix, source)`

* Simulate a message being sent to all players
* `name`: Sender player name
* `msg`: Message to send
* `prefix`: An optional string to prefix the colourized message and username
* `source`: Used by ranks to allow compatibility between ranks and chat3

Ignore API
----------

`chat3.ignore.get(name)`

* Returns table of ignored players (e.g.
* `{ignoring = {name1 = true, ...}, ignored_by = {name2 = true, ...}}`)
* `name`: Player username

`chat3.ignore.set(name, list)`

* Set a player's ignore list
* `name`: Player username
* `list`: Table of names (e.g. (e.g.
* `{ignoring = {name1 = true, ...}, ignored_by = {name2 = true, ...}}`)

`chat3.ignore.add_name(name, ignore)`

* Returns `success` if `ignore` was added to `name`'s `ignoring` list and `name`
* to `ignore`'s `ignored_by` list
* `name`: Name of player to whose ignore list `ignore` should be added
* `ignore`: Player username to ignore

`chat3.ignore.remove_name(name, unignore)`

* Returns `success` if `ignore` was removed from `name`'s `ignoring` list and
* `name` from `ignore`'s `ignored_by` list

`chat3.ignore.clear(name)`

* Returns `success` if `name`'s ignore list was cleared
* This should be used over `chat3.ignore.set(name, nil)` as it also clears
* `ignored_by` lists and notifies no longer ignored players.
`name`: Name of player whose ignore list should be cleared

`chat3.ignore.can(name, check)`

* Returns `true` if the player can be ignored
* If the player cannot be ignored they will be removed from the ignore list of
* the player ignoring them.
* `name`: Name of player whose ignore list is to be checked
* `check`: Player username to check if ignored

`chat3.ignore.is(name, check)`

* Returns `true` if the player is being ignored
* `name`: Name of player whose ignore list is to be checked
* `target`: Player Object of player to check the ignore list of

`chat3.ignore.add(name, ignore)`

* Returns `success, message` after attempting to ignore a player
* Verbose, chat-friendly version of `chat3.ignore.add_name`
* `name`: Name of player to whose ignore list `ignore` should be added
* `ignore`: Player username to attempt to ignore

`chat3.ignore.remove(name, unignore)`

* Returns `success, message` after attempting to remove a player from another's
* ignore list.
* Verbose, chat-friendly version of `chat3.ignore.remove_name`
* `name`: Name of player from whose ignore list `unignore` should be removed
* `player`: Player username to attempt to unignore

`chat3.ignore.check(name, check)`

* Returns `result, message` after attempting to find out if `check` is being
* ignored by `name`.
* `name`: Name of player whose ignore list should be checked
* `check`: Player username to check if being ignored

`chat3.ignore.list(name, subtable)`

* Returns a table containing a list of players being ignored by `name`, or `nil`
* if none, in a format suitable for use with `table.concat` (e.g. `{name1, name2, ...}`).
* `name`: Name of player whose ignore list should be listed
* `subtable`: Table to return (`ignoring` or `ignored_by`)

Alternate Username API
----------------------

`chat3.alt.get(name)`

* Returns table of alternate usernames (e.g. `{name1 = true, name2 = true, ...}`)
* `name`: Player username

`chat3.alt.set(name, list)`

* Set a player's alternate username list
* `name`: Player username
* `list`: Table of alternate usernames (e.g. `{name1 = true, name2 = true, ...}`)

`chat3.alt.add(name, alt)`

* Add an alternate username (returns `nil` if max has been reached or if the
	alternate username already exists)
* `name`: Base player username
* `alt`: New alternate username

`chat3.alt.remove(name, alt)`

* Remove an alternate username (returns `nil` if the username already does not
	exist)
* `name`: Base player username
* `alt`: Alternate username to remove

`chat3.alt.list(name)`

* Returns a table with a list of alternate usernames (suitable for `table.concat`)
* `name`: Player username
