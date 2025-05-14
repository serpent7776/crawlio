CFLAGS = -Wall -Wextra -pedantic -std=c11 -O2 -ggdb3
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
LIBDIR = $(PREFIX)/lib

.PHONY: all
all: crawlio.so

crawlio.so: crawlio.c
	$(CC) $(CFLAGS) -shared -fPIC -ldl crawlio.c -o crawlio.so

.PHONY: clean
clean:
	rm -f crawlio.so

.PHONY: install
install: crawlio.so
	install -d $(DESTDIR)$(BINDIR)
	install -d $(DESTDIR)$(LIBDIR)
	install -m 755 crawlio.sh $(DESTDIR)$(BINDIR)/crawlio
	install -m 644 crawlio.so $(DESTDIR)$(LIBDIR)/crawlio.so
	sed -i "s|CRAWLIO_LIB=\"./crawlio.so\"|CRAWLIO_LIB=\"$(LIBDIR)/crawlio.so\"|" $(DESTDIR)$(BINDIR)/crawlio

.PHONY: uninstall
uninstall:
	rm -f $(DESTDIR)$(BINDIR)/crawlio
	rm -f $(DESTDIR)$(LIBDIR)/crawlio.so
