DEPS = bitbash/bmplib.sh
SRCDIR = src
PLUGINS = mtop.5s.sh

all: $(PLUGINS)

clean:
	rm -f $(PLUGINS) $(DEPS)

# Plugin sources are kept in `src`
#
# Libraries and files included using `.` or `source` are expanded inline
# This keeps the plugin source clean, while the "compiled" plugin in the
# base directory is a single self-contained file for easy installation in
# the BitBar plugin directory.

$(PLUGINS): %: $(SRCDIR)/% $(DEPS)
	@echo Generating $@
	@(cd $(SRCDIR); awk '$$1 ~/^\.|source$$/ {system("cat " $$2); next}; {print;}') < $< > $@
	@chmod +x $@

bitbash/bmplib.sh:
	git submodule update --init
	cd bitbash; git checkout .
