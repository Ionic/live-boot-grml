# Makefile

SHELL := sh -e

LANGUAGES = $(shell cd manpages/po && ls)

SCRIPTS = bin/* hooks/* scripts/live scripts/live-functions scripts/live-helpers scripts/*/*

all: build

test:
	@echo -n "Checking for syntax errors"

	@for SCRIPT in $(SCRIPTS); \
	do \
		sh -n $${SCRIPT}; \
		echo -n "."; \
	done

	@echo " done."

	@# We can't just fail yet on bashisms (FIXME)
	@if [ -x "$$(which checkbashisms 2>/dev/null)" ]; \
	then \
		echo -n "Checking for bashisms"; \
		for SCRIPT in $(SCRIPTS); \
		do \
			checkbashisms -f -x $${SCRIPT} || true; \
			echo -n "."; \
		done; \
		echo " done."; \
	else \
		echo "W: checkbashisms - command not found"; \
		echo "I: checkbashisms can be optained from: "; \
		echo "I:   http://git.debian.org/?p=devscripts/devscripts.git"; \
		echo "I: On Debian based systems, checkbashisms can be installed with:"; \
		echo "I:   apt-get install devscripts"; \
	fi

build:
	@echo "Nothing to build."

install:
	# Installing executables
	mkdir -p $(DESTDIR)/sbin
	cp bin/live-new-uuid bin/live-snapshot bin/live-swapfile $(DESTDIR)/sbin

	mkdir -p $(DESTDIR)/usr/share/live-boot
	cp bin/live-preseed bin/live-reconfigure local/languagelist $(DESTDIR)/usr/share/live-boot

	mkdir -p $(DESTDIR)/usr/share/initramfs-tools
	cp -r hooks scripts $(DESTDIR)/usr/share/initramfs-tools

	# Installing docs
	mkdir -p $(DESTDIR)/usr/share/doc/live-boot
	cp -r COPYING docs/* $(DESTDIR)/usr/share/doc/live-boot

	mkdir -p $(DESTDIR)/usr/share/doc/live-boot/examples
	cp -r etc/* $(DESTDIR)/usr/share/doc/live-boot/examples
	# (FIXME)

	# Installing manpages
	for MANPAGE in manpages/en/*; \
	do \
		SECTION="$$(basename $${MANPAGE} | awk -F. '{ print $$2 }')"; \
		install -D -m 0644 $${MANPAGE} $(DESTDIR)/usr/share/man/man$${SECTION}/$$(basename $${MANPAGE}); \
	done

	for LANGUAGE in $(LANGUAGES); \
	do \
		for MANPAGE in manpages/$${LANGUAGE}/*; \
		do \
			SECTION="$$(basename $${MANPAGE} | awk -F. '{ print $$3 }')"; \
			install -D -m 0644 $${MANPAGE} $(DESTDIR)/usr/share/man/$${LANGUAGE}/man$${SECTION}/$$(basename $${MANPAGE} .$${LANGUAGE}.$${SECTION}).$${SECTION}; \
		done; \
	done

uninstall:
	# Uninstalling executables
	rm -f $(DESTDIR)/sbin/live-snapshot $(DESTDIR)/sbin/live-swapfile
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/sbin > /dev/null 2>&1 || true

	rm -rf $(DESTDIR)/usr/share/live-boot

	rm -f $(DESTDIR)/usr/share/initramfs-tools/hooks/live
	rm -rf $(DESTDIR)/usr/share/initramfs-tools/scripts/live*
	rm -f $(DESTDIR)/usr/share/initramfs-tools/scripts/local-top/live

	rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr/share/initramfs-tools/hooks > /dev/null 2>&1 || true
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr/share/initramfs-tools/scripts/local-top > /dev/null 2>&1 || true
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr/share/initramfs-tools/scripts > /dev/null 2>&1 || true
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr/share/initramfs-tools > /dev/null 2>&1 || true
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr/share > /dev/null 2>&1 || true
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr > /dev/null 2>&1 || true

	# Uninstalling docs
	rm -rf $(DESTDIR)/usr/share/doc/live-boot
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr/share/doc > /dev/null 2>&1 || true
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr/share > /dev/null 2>&1 || true
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr > /dev/null 2>&1 || true

	# Uninstalling manpages
	for MANPAGE in manpages/en/*; \
	do \
		SECTION="$$(basename $${MANPAGE} | awk -F. '{ print $$2 }')"; \
		rm -f $(DESTDIR)/usr/share/man/man$${SECTION}/$$(basename $${MANPAGE} .en.$${SECTION}).$${SECTION}; \
	done

	for LANGUAGE in $(LANGUAGES); \
	do \
		for MANPAGE in manpages/$${LANGUAGE}/*; \
		do \
			SECTION="$$(basename $${MANPAGE} | awk -F. '{ print $$3 }')"; \
			rm -f $(DESTDIR)/usr/share/man/$${LANGUAGE}/man$${SECTION}/$$(basename $${MANPAGE} .$${LANGUAGE}.$${SECTION}).$${SECTION}; \
		done; \
	done

	for SECTION in $(ls manpages/en/* | awk -F. '{ print $2 }'); \
	do \
		rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr/share/man/man$${SECTION} > /dev/null 2>&1 || true; \
		rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr/share/man/*/man$${SECTION} > /dev/null 2>&1 || true; \
	done

	rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr/share/man > /dev/null 2>&1 || true
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr/share > /dev/null 2>&1 || true
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr > /dev/null 2>&1 || true

	rmdir --ignore-fail-on-non-empty $(DESTDIR) > /dev/null 2>&1 || true

clean:
	@echo "Nothing to clean."

distclean: clean
	@echo "Nothing to distclean."

reinstall: uninstall install
