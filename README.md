# p1xbraten

This repository contains the source for my client mod, as well as the patches applied to the vanilla Sauerbraten source to get there.

<p>
<figure>
  <blockquote>mouse input feels smooth af with your client now @pix</blockquote>
  —Acuerta, <cite><a href='https://discord.com/channels/186571398422986754/388590104387649537/798528659400032286'>12 Jan 2021</a></cite>
</figure>
</p>

- [Patches](#patches)
  - [moviehud.patch](#moviehudpatch)
  - [scoreboard.patch](#scoreboardpatch)
  - [hudfragmessages.patch](#hudfragmessagespatch)
  - [fullconsole.patch](#fullconsolepatch)
  - [hudscore.patch](#hudscorepatch)
  - [serverbrowser.patch](#serverbrowserpatch)
  - [listteams.patch](#listteamspatch)
  - [tex_commands.patch](#tex_commandspatch)
  - [decouple_framedrawing.patch](#decouple_framedrawingpatch)
  - [crosshaircolor.patch](#crosshaircolorpatch)
  - [zenmode.patch](#zenmodepatch)
  - [gamehud.patch](#gamehudpatch)
  - [chat_highlight_words.patch](#chat_highlight_wordspatch)
  - [modversion.patch](#modversionpatch)
  - [minimizedframes.patch](#minimizedframespatch)
  - [hasflag.patch](#hasflagpatch)
  - [playerspeed.patch](#playerspeedpatch)
  - [up_down_hover.patch](#up_down_hoverpatch)
  - [paused_spec_movement.patch](#paused_spec_movementpatch)
  - [checkupdate.patch](#checkupdatepatch)
  - [clientdemo.patch](#clientdemopatch)
  - [colored_weapon_trails.patch](#colored_weapon_trailspatch)
- [Server Patches](#server-patches)
  - [authservers.patch](#authserverspatch)
  - [serverlogging.patch](#serverloggingpatch)
  - [server_ogzs.patch](#server_ogzspatch)
- [Installation](#installation)
  - [Windows](#windows)
  - [macOS](#macos)
  - [Linux](#linux)
- [Menu](#menu)
- [Project Structure](#project-structure)
- [Building your own binary](#building-your-own-binary)
  - [Using fresh upstream sources](#using-fresh-upstream-sources)
  - [Debugging](#debugging)


## Patches

a.k.a. Features

### [moviehud.patch](./patches/moviehud.patch)

- adds `namesabovehead` toggle: when 0, hides the names above players' models (usually rendered as particle text), while keeping status icons for health boost, armor and quad

### [scoreboard.patch](./patches/scoreboard.patch)

- enables suicide and detailed, per-weapon damage recording

  Note that suicide and damage recording is only accurate in games you observed from the beginning. When you join a running game, all previous damage is unknown, and suicides are only initialized from negative frag counts.

- cleans up the scoreboard look (for example, right-justifies numeric scoreboard columns)

- adds scoreboard toggles:
    - `showflags`: when 1, shows the number of flags scored by a player; always hidden in non-flag modes
    - `showsuicides`: when 1, shows how often each player suicided
    - `showkpd`: when 1, shows each player's frags/death ratio
    - `showaccuracy`: when 1, shows each player's overall accuracy
    - `showdamage`: when 1, shows each player's overall damage dealt; when 2, shows each player's overall net damage (= dealt - received); always hidden in insta modes
    - `showdamagereceived`: when 1, shows each player's damage received

  ![example screenshots](https://i.imgur.com/hsCY56E.gif)

- makes the following built-in cubescript commands take an optional player CN as argument:
    - `getfrags`
    - `getflags`
    - `getdeaths`
    - `getaccuracy`
    - `gettotaldamage`
    - `gettotalshots`
    - `getweapon`

  Omitting the argument will return the information about `hudplayer`, i.e. yourself (if playing) or the player you're currently spectating.

- adds damage-related cubescript commands:
    - `getdamagepotential` (same as `gettotalshots` when not filtering by weapon)
    - `getdamagedealt` (same as `gettotaldamage` when not filtering by weapon)
    - `getdamagereceived`
    - `getdamagewasted` (= potential − dealt)
    - `getnetdamage` (= dealt − received)

  All of the new damage-related commands (as well as `getaccuracy`) default to showing `hudplayer`'s stats across all weapons. However, they all take two optional integer arguments to query stats of a certain player and optionally for a specific weapon: `/<cmd> [cn] [weapon]` (use -1 as CN to query specific weapon stats about `hudplayer`).

  To show comed-like statistics in the lower right corner, copy the contents of [`stats_gamehud.cfg`](./data/p1xbraten/stats_gamehud.cfg) into your `autoexec.cfg`.

### [hudfragmessages.patch](./patches/hudfragmessages.patch)

- enables frag messages showing the weapon used to complete the frag (on by default)
- adds the following variables:
    - `hudfragmessages`: 0 disables all frag messages, 1 enables them for all modes, 2 enables them for non-insta modes only
    - `maxhudfragmessages`: how many messages to show at most (between 1 and 10)
    - `hudfragmessageduration`: how long each message will be shown, in seconds, between 0 and 10
    - `hudfragmessagefade`: 0 or 1: whether or not to fade out messages
    - `hudfragmessagex`: horizontal position (between 0.0 and 1.0) where messages will appear
    - `hudfragmessagey`: vertical position (between 0.0 and 1.0) where the newest message will appear
    - `hudfragmessagescale`: size of the messages, between 0.0 and 1.0
    - `hudfragmessagestackdir`: direction in which to stack old messages: -1 to stack upwards, 1 to stack downwards, 0 to stack towards the closes edge of the screen depending on `hudfragmessagey`
    - `hudfragmessagefilter`: bitfield filter var (like confilter), e.g. 0x3800 shows all players' frags, suicides, and teamkills
    - `hudfragmessageforcecolors`: when 1 (default), uses colored names, even in non-team modes

You can easily configure the hud frag messages using the [improved menu](#menu) (options → hud → adjust hud frag messages).

![fragmessages](https://i.imgur.com/K4GL6oB.png)

### [fullconsole.patch](./patches/fullconsole.patch)

- removes the guiskin background of fullconsole in favor of a gradient background on the left
- improves interplay of scoreboard and fullconsole
- `fullconsize` is deprecated and unused, instead the console always takes up all available space
- adds `fullconalpha` var: sets the opacity of fullconsole's left edge in percent (from 1 to 100)

### [hudscore.patch](./patches/hudscore.patch)

- hides hudscore when there is just one team/player

### [serverbrowser.patch](./patches/serverbrowser.patch)

- styles the serverbrowser to be consistent with the cleaned up scoreboard
- divides 'players' column into 'players' and 'slots'
- right-justifies ping, players, slots, and port columns

### [listteams.patch](./patches/listteams.patch)

- adds `listteams` command that returns a list of names of non-empty teams (according to filters) when two or more teams exist and an empty string otherwise (`listteams [includeself?] [includebots?] [includespecs?]`)
- extends `listclients` command to allow omitting spectators and only listing clients of a certain team (`listclients [includeself?] [includebots?] [includespecs?] [teamname?]`)

[The updated menu](#menu) includes a better master menu thanks to these changes:

![master menu](https://i.imgur.com/doC2IcB.png)

### [tex_commands.patch](./patches/tex_commands.patch)

- adds `settex <id>` command to apply a texture by ID
- adds `replacetex <old> <new> [insel?]` command to replace a texture with another by specifying their IDs

### [decouple_framedrawing.patch](./patches/decouple_framedrawing.patch)

- removes fps-induced limiting of the main loop (for example, input & network processing were affected by `maxfps`)
- introduce `maxtps` var to limit the main loop independently from `maxfps` (for example to save power): 0 to disable limiting (default), 100..1000 to set how many ticks per second are allowed; `maxfps` overrides `maxtps` if `maxfps > maxtps`

This patch allows using `maxfps` without compromising on the frequency of input polling and network event processing. In vanilla Sauerbraten, `maxfps` limits the whole game's main loop. This patch removes the main loop limiting and instead skips only frame drawing until a new frame is needed, but still processes network events and player input on every main loop iteration.

While vanilla Sauerbraten is truly unlimited after `/maxfps 0`, p1xbraten's mainloop can additionally be limited using the `maxtps` variable. Setting `maxfps` to any value other than 0 also forces a maximum tick frequency of 1000 (but respects lower settings), even if you set `maxtps 0`, so that p1xbraten can prioritise frame draw timing. Set both `maxfps` and `maxtps` to 0 to get vanilla's unlimited behavior back.

Using `maxfps` and `maxtps`, you can optimize for different goals:

- for lowest average latency, use `/maxtps 0` and `/vsync 0`
- for lowest consistent latency, use `/maxfps 0`, `/vsync 0`, and set `maxtps` to the highest value that gives you a stable fps counter on your system
- to use fewer resources and save laptop battery, use `/maxfps 0`, and set `maxtps` to the lowest value that gives you smooth graphics

### [crosshaircolor.patch](./patches/crosshaircolor.patch)

- adds `crosshaircolor` variable to set a base crosshair color (for example, `/crosshaircolor 0 255 0` for pleasant green)

### [zenmode.patch](./patches/zenmode.patch)

- adds `zenmode` variable: if 1, hides non-essential console messages:
  - server messages
  - chat and team chat messages from spectators
  - joins (all), leaves and renames (of spectators)

### [gamehud.patch](./patches/gamehud.patch)

- properly right-justifies gamehud, wallclock, showfps, and/or showfpsrange lines
- adds a useful playerlist showing who's alive vs. dead when spectating in the lower right corner
- adds `isdead <cn>` command to check if a player is currently dead (only works when you are spectating)

<div align="center"><img alt="gamehud with player state" src="https://i.imgur.com/8kfmhSK.gif" /></div>

### [chat_highlight_words.patch](./patches/chat_highlight_words.patch)

- lets you define words that trigger a sound when they appear in chat or team chat
- adds `addchathighlightword <word>` command (for example, put `addchathighlightword pix` and `addchathighlightword p1x` into autoexec.cfg to receive a highlight on both spellings)
- adds `chathighlightsound` variable to set the sound to play (default: `free/itempick`)

### [modversion.patch](./patches/modversion.patch)

- adds the `p1xbratenversion` variable (read-only): contains the version of your installation as a string
- adds the `getclientp1xbratenversion <cn>` command: returns the version of p1xbraten the player is running
- adds the `enablep1xbratendetection` variable: set to 0 to disable broadcasting your p1xbraten version (and detecting other p1xbraten players yourself)

This lets you see wether a player connected to the same server as you is using p1xbraten, and what version. It relies on p1xbraten clients sending additional packets to the server, which the server then broadcasts to all other clients. This means other players can tell you're using p1xbraten (and what version). No information other than "I use p1xbraten, version X.Y.Z" is sent. No information is sent to me (p1x) or any third party. Opt out if you are firefly!

For an overview of who uses p1xbraten, you can run `/showgui p1xbratenusage`.

### [minimizedframes.patch](./patches/minimizedframes.patch)

- adds the `minimizedframes` toggle: when 1, frames will always be drawn, even when they would usually be skipped because p1xbraten is minimized

### [hasflag.patch](./patches/hasflag.patch)

- adds the `hasflag <cn>` command: returns 1 if the specfied player carries a flag

### [playerspeed.patch](./patches/playerspeed.patch)

- adds the `playerspeed` variable (read-only): returns the hud player's speed (in units per second)

### [up_down_hover.patch](./patches/up_down_hover.patch)

- adds the `up`, `down` and `hover` movement commands:
  - `up`/`down` induce movement up or down relative to the player's view
  - `hover` prevents any change in height from forward/backward movement and making `up` and `down` work along the world's Z axis

  all three commands only work while editing or spectating

### [paused_spec_movement.patch](./patches/paused_spec_movement.patch)

- enables free movement as spectator while the game is paused

### [checkupdate.patch](./patches/checkupdate.patch)

- adds the `checkupdate` command to check if a newer version of p1xbraten is available

### [clientdemo.patch](./patches/clientdemo.patch)

- adds the `recordclientdemo <0|1|2>` command: 1 schedules, 0 cancels demo recording for the next match; 2 starts recording a demo immediately
- adds the `stopclientdemo` command: stops an ongoing demo recording

Client-side demos record the game as you experience it, and work independently of server-side demo recording. They also work locally, without being connected to any server.

### [colored_weapon_trails.patch](./patches/colored_weapon_trails.patch)

- adds the `trailcolor[shotgun|chaingun|rocketlauncher|rifle|grenadelauncher|pistol]` vars that change the respective weapon's projectile/particle trail
- adds the `settrailcolor <SG|CG|RL|RI|GL|PI> <color>` command (for convenience: changing the variables directly also works)


## Server Patches

These are the patches that make p1x.pw different from other servers.

### [authservers.patch](./patches/authservers.patch)

- adds `/addauthserver <key_domain> <hostname> <port> <privilege>` server command to add an additional auth backend (other than the master server)

For example, you can put `addauthserver "p1x.pw" "p1x.pw" 28787 "m"` into your `server-init.cfg` to allow users registered with my master server to claim auth on your server.

### [serverlogging.patch](./patches/serverlogging.patch)

Improves logging when running a dedicated server:

- adds `logtime` variable: if 1, all log messages are prepended with ISO date and time (e.g. `[2021-04-06 17:12:05]`)
- includes CN in connect, disconnect, chat, team chat log messages
- logs a "join" message including CN and player name
- logs map changes
- logs all privilege changes

### [server_ogzs.patch](./patches/server_ogzs.patch)

- allows using slim .ogz files (see https://github.com/sauerbraten/genserverogz) on the server without getting `checkmaps` errors


## Installation

The latest builds are always at https://github.com/sauerbraten/p1xbraten/releases/latest.

### Windows

Download p1xbraten_\<version\>_setup.exe from the link above and execute it. p1xbraten will be installed alongside your existing Sauerbraten installation.

### macOS

1. Open Finder
2. Press Shift + Command + G (⇧⌘G)
3. Go to `/Applications/sauerbraten.app/Contents/MacOS/`
4. Make a copy of sauerbraten_universal (in case you want to go back to the vanilla client in the future)
5. Download sauerbraten_universal from the link above and drag it into the Finder window, replacing the old file
6. Open a Terminal and type `chmod +x ` (note the space at the end), then drag the sauerbraten_universal file into the Terminal window
7. When it says `chmod +x /Applications/sauerbraten.app/Contents/MacOS/sauerbraten_universal`, press Enter to execute

### Linux

Download linux_64_client from the link above and put it into bin_unix/ inside of your Sauerbraten directory (*after* backing up the original file), then `chmod +x bin_unix/linux_64_client`.


## Menu

For easy configuration of the new features, an updated version of the `menus.cfg` file is automatically installed when you start p1xbraten for the first time. The new file brings UI options for added features and also includes various cleanups of the vanilla GUI.

If you do not want to use the p1xbraten menus, run `/usep1xbratenmenus 0`.


## Project Structure

- `patches/` has all the patch files that turn vanilla Sauerbraten into p1xbraten
- `src/` has the vanilla source tree with all patches already applied
- `Makefile` has `make` commands to work with the patches and an SVN checkout of vanilla
- `data/` contains p1xbraten specific cubescript files: each files exist as plain text .cfg file as well as gzipped, xxd'ed file for embedding during compilation
- `bin/`, `bin64/` and `bin_unix/` are empty and only exist for CI builds
- `sauerbraten.app/` contains SDL2 for macOS builds
- `p1xbraten.bat`, `server.sh`, and `start.sh` are custom p1xbraten launch scripts (`start.sh` and `server.sh` use `~/.p1xbraten` as user directory instead of `~/.sauerbraten`)
- `p1xbraten.vcxproj` is a file so Appveyor can build 32- and 64-bit Windows binaries in a single run


## Building your own binary

*You don't have to do this if you already followed the installation instructions above and just want to play!*

On Linux and macOS, just run `make install` **inside the src/ directory** (given you installed the usual Sauerbraten dependencies). On Windows, open [src/vcpp/sauerbraten.vcxproj](./src/vcpp/sauerbraten.vcxproj) with Visual Studio and build in there.

This will put the resulting binary into the usual place inside this repo. To use it, you have to copy it over to the same place in your actual Sauerbraten installation. On Linux, the [start.sh](./start.sh) script will launch the new binary from inside this repository, using the Sauerbraten files in $SAUER_DIR and `~/.p1xbraten` as user data directory.

### Using fresh upstream sources

On Linux and macOS, you can build my client using fresh vanilla sources. Set $SAUER_DIR to the path of your Sauerbraten directory, then use `make` and `make install` **in the repository root**:

```
export SAUER_DIR=~/sauerbraten-code
make
make install
```

`make` will copy the src/ directory from $SAUER_DIR, apply all patches and run `make` inside src/; `make install` will run `make install` inside src/.

### Debugging

On Linux, I replace `-O3` with `-g -rdynamic` in the [Makefile](./src/Makefile), and `exec` with `exec gdb --args` in [start.sh](./start.sh) to set up debugging. Then:

```
make clean && make && make install
./start.sh
```

In gdb, typing `run` starts p1xbraten.