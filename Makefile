SHELL := /bin/bash

.PHONY: build install clean anticheat linux macos windows apply-patches gzip-cfgs embed-cfgs clean-sauer update-src from-patches changes-to-patch ensure-sauer-dir

build:
	cd src && make --jobs=8

install:
	cd src && make --jobs=8 install

clean:
	cd src && make clean
	cd src/enet && make clean

key:
	dd if=/dev/random bs=1 count=256 of=src/anticheat/key
	xxd -i src/anticheat/key src/anticheat/key.h

linux macos windows: export ANTICHEAT=1
# linux macos windows: export DEBUG=1
linux macos windows: | clean key
	source secrets.env && go run encrypt_credentials.go < src/anticheat/key && \
	cd src && \
	export TARGET="x86_64-$@" && \
	make --jobs=8 install

debian: clean
	dd if=/dev/random of=Dockertrigger count=64 && \
	podman build \
	--file Dockerfile.debian-11 \
	--security-opt label=disable \
	--volume=$(PWD)/src:/src \
	--volume=$(PWD)/bin_unix:/bin_unix \
	--volume=$(PWD)/data:/data:ro \
	.

PATCH=patch --strip=0 --remove-empty-files --ignore-whitespace --no-backup-if-mismatch

apply-patches:
	$(PATCH) < patches/modconfig.patch
	$(PATCH) < patches/modversion.patch
	$(PATCH) < patches/moviehud.patch
	$(PATCH) < patches/hasflag.patch
	$(PATCH) < patches/colors.patch
	$(PATCH) < patches/scoreboard.patch
	$(PATCH) < patches/hudfragmessages.patch
	$(PATCH) < patches/fullconsole.patch
	$(PATCH) < patches/hudscore.patch
	$(PATCH) < patches/serverbrowser.patch
	$(PATCH) < patches/listteams.patch
	$(PATCH) < patches/execfile.patch
	$(PATCH) < patches/embedded_cfgs.patch
	$(PATCH) < patches/tex_commands.patch
	$(PATCH) < patches/decouple_framedrawing.patch
	$(PATCH) < patches/crosshaircolor.patch
	$(PATCH) < patches/chat_highlight_words.patch
	$(PATCH) < patches/zenmode.patch
	$(PATCH) < patches/authservers.patch
	$(PATCH) < patches/serverlogging.patch
	$(PATCH) < patches/gamehud.patch
	$(PATCH) < patches/server_ogzs.patch
	$(PATCH) < patches/minimizedframes.patch
	$(PATCH) < patches/playerspeed.patch
	$(PATCH) < patches/up_down_hover.patch
	$(PATCH) < patches/paused_spec_movement.patch
	$(PATCH) < patches/clientdemo.patch
	$(PATCH) < patches/colored_weapon_trails.patch
	$(PATCH) < patches/serverevents.patch
	$(PATCH) < patches/crosshairreloadfade.patch
	$(PATCH) < patches/managed_games.patch
	$(PATCH) < patches/better_console.patch
	$(PATCH) < patches/autoauthdomains.patch
	$(PATCH) < patches/nextfollowteam.patch
	$(PATCH) < patches/proxy_setip.patch
	$(PATCH) < patches/server_demo_name.patch
	$(PATCH) < patches/spec_teleports.patch
	$(PATCH) < patches/demo_info_message.patch
	$(PATCH) < patches/extinfo_mod_id.patch
	$(PATCH) < patches/anticheat.patch
	$(PATCH) < patches/setfont.patch
	cd src && make depend

gzip-cfgs:
	gzip --keep --force --best --no-name data/p1xbraten/menus.cfg && xxd -i - data/p1xbraten/menus.cfg.gz.xxd < data/p1xbraten/menus.cfg.gz
	gzip --keep --force --best --no-name data/p1xbraten/master.cfg && xxd -i - data/p1xbraten/master.cfg.gz.xxd < data/p1xbraten/master.cfg.gz
	gzip --keep --force --best --no-name data/p1xbraten/gamehud.cfg && xxd -i - data/p1xbraten/gamehud.cfg.gz.xxd < data/p1xbraten/gamehud.cfg.gz
	gzip --keep --force --best --no-name data/p1xbraten/keymap.cfg && xxd -i - data/p1xbraten/keymap.cfg.gz.xxd < data/p1xbraten/keymap.cfg.gz

embed-cfgs: gzip-cfgs
	sed -i "s/0,\/\/menuscrc/0x$(shell crc32 data/p1xbraten/menus.cfg),/" src/p1xbraten/embedded_cfgs.cpp
	sed -i "s/embeddedfile<0> menuscfg/embeddedfile<$(shell stat --printf="%s" data/p1xbraten/menus.cfg.gz)> menuscfg/" src/p1xbraten/embedded_cfgs.cpp
	sed -i "s/0,\/\/mastercrc/0x$(shell crc32 data/p1xbraten/master.cfg),/" src/p1xbraten/embedded_cfgs.cpp
	sed -i "s/embeddedfile<0> mastercfg/embeddedfile<$(shell stat --printf="%s" data/p1xbraten/master.cfg.gz)> mastercfg/" src/p1xbraten/embedded_cfgs.cpp
	sed -i "s/0,\/\/gamehudcrc/0x$(shell crc32 data/p1xbraten/gamehud.cfg),/" src/p1xbraten/embedded_cfgs.cpp
	sed -i "s/embeddedfile<0> gamehudcfg/embeddedfile<$(shell stat --printf="%s" data/p1xbraten/gamehud.cfg.gz)> gamehudcfg/" src/p1xbraten/embedded_cfgs.cpp
	sed -i "s/0,\/\/keymapcrc/0x$(shell crc32 data/p1xbraten/keymap.cfg),/" src/p1xbraten/embedded_cfgs.cpp
	sed -i "s/embeddedfile<0> keymapcfg/embeddedfile<$(shell stat --printf="%s" data/p1xbraten/keymap.cfg.gz)> keymapcfg/" src/p1xbraten/embedded_cfgs.cpp
	cd src && make depend

ifndef SAUER_DIR
ifneq (,$(wildcard ~/sauerbraten-code))
SAUER_DIR=~/sauerbraten-code
endif
endif

clean-sauer: ensure-sauer-dir
	cd $(SAUER_DIR) && \
		svn cleanup . --remove-unversioned --remove-ignored && \
		svn revert --recursive --remove-added .
	cd $(SAUER_DIR)/src/enet && make clean
	cd $(SAUER_DIR)/src && make clean

VANILLA_SOURCE_FILES=enet,engine,fpsgame,shared
P1XBRATEN_SOURCE_FILES=$(VANILLA_SOURCE_FILES),p1xbraten,anticheat/anticheat.cpp

update-src: clean-sauer
	rm --recursive --force src/{$(P1XBRATEN_SOURCE_FILES)}
	rsync --recursive --ignore-times --times --exclude=".*" $(SAUER_DIR)/src/{$(VANILLA_SOURCE_FILES)} src/

from-patches: | update-src apply-patches embed-cfgs build

changes-to-patch:
	git diff --no-prefix --ignore-all-space --staged data/p1xbraten src/{$(P1XBRATEN_SOURCE_FILES)} > patches/new_changes.patch

ensure-sauer-dir:
ifndef SAUER_DIR
	$(error SAUER_DIR is undefined)
endif
