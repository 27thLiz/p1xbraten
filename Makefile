.PHONY: build install clean apply-patches gzip-menus _include-menus clean-sauer update-src apply-to-vanilla check-env

PATCH=patch --strip=0 --remove-empty-files --ignore-whitespace

ifndef SAUER_DIR
ifneq (,$(wildcard ~/sauerbraten-code))
	SAUER_DIR=~/sauerbraten-code
endif
endif

build: update-src apply-patches gzip-menus _include-menus
	cd src && make client

install:
	cd src && make install

clean:
	cd src && make clean
	cd src/enet && make clean

apply-patches:
	dos2unix src/vcpp/sauerbraten.vcxproj
	$(PATCH) < patches/modversion.patch
	$(PATCH) < patches/moviehud.patch
	$(PATCH) < patches/scoreboard.patch
	$(PATCH) < patches/macos_builds.patch
	$(PATCH) < patches/hudfragmessages.patch
	$(PATCH) < patches/fullconsole.patch
	$(PATCH) < patches/hudscore.patch
	$(PATCH) < patches/serverbrowser.patch
	$(PATCH) < patches/listteams.patch
	$(PATCH) < patches/no_server_build.patch
	$(PATCH) < patches/extrapings.patch
	$(PATCH) < patches/execfile.patch
	$(PATCH) < patches/include_p1xbraten_menus.patch
	$(PATCH) < patches/tex_commands.patch
	$(PATCH) < patches/decouple_framedrawing.patch
	unix2dos src/vcpp/sauerbraten.vcxproj

gzip-menus:
	gzip --keep --force --best --no-name data/p1xbraten/menus.cfg && xxd -i - data/p1xbraten/menus.cfg.gz.xxd < data/p1xbraten/menus.cfg.gz
	gzip --keep --force --best --no-name data/p1xbraten/master.cfg && xxd -i - data/p1xbraten/master.cfg.gz.xxd < data/p1xbraten/master.cfg.gz
	gzip --keep --force --best --no-name data/p1xbraten/gamehud.cfg && xxd -i - data/p1xbraten/gamehud.cfg.gz.xxd < data/p1xbraten/gamehud.cfg.gz

_include-menus:
	sed -i "s/menuscfggzlen = 0;/menuscfggzlen = $(shell stat --printf="%s" data/p1xbraten/menus.cfg.gz);/" src/fpsgame/p1xbraten_menus.cpp
	sed -i "s/mastercfggzlen = 0;/mastercfggzlen = $(shell stat --printf="%s" data/p1xbraten/master.cfg.gz);/" src/fpsgame/p1xbraten_menus.cpp
	sed -i "s/gamehudcfggzlen = 0;/gamehudcfggzlen = $(shell stat --printf="%s" data/p1xbraten/gamehud.cfg.gz);/" src/fpsgame/p1xbraten_menus.cpp

clean-sauer: check-env
	cd $(SAUER_DIR) && \
		svn cleanup . --remove-unversioned --remove-ignored && \
		svn revert --recursive --remove-added .
	cd $(SAUER_DIR)/src/enet && make clean
	cd $(SAUER_DIR)/src && make clean

update-src: clean-sauer
	rm --recursive --force src/
	rsync --recursive --ignore-times --times --exclude=".*" $(SAUER_DIR)/src .

apply-to-vanilla: update-src apply-patches
	rm --recursive --force $(SAUER_DIR)/src/*
	rsync --recursive --ignore-times --times --exclude=".*" ./src/* $(SAUER_DIR)/src/

check-env:
ifndef SAUER_DIR
	$(error SAUER_DIR is undefined)
endif
