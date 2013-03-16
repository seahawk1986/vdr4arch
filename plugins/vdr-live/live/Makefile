#
# Makefile for a Video Disk Recorder plugin
# Adapted to the new VDR makefile environment by Stefan Hofmann
#
# $Id$

# The official name of this plugin.
# This name will be used in the '-P...' option of VDR to load the plugin.
# By default the main source file also carries this name.

PLUGIN = live

### The version number of this plugin (taken from the setup header file):

VERSION = $(shell grep '\#define LIVEVERSION ' setup.h | awk '{ print $$3 }' | sed -e 's/[";]//g')

TNTVERSION = $(shell tntnet-config --version | sed -e's/\.//g' | sed -e's/pre.*//g' | awk '/^..$$/ { print $$1."000"} /^...$$/ { print $$1."00"} /^....$$/ { print $$1."0" } /^.....$$/ { print $$1 }')
TNTVERS7   = $(shell ver=$(TNTVERSION); if [ $$ver -ge "1606" ]; then echo "yes"; fi)

VERSIONSUFFIX = gen_version_suffix.h

### The directory environment:

# Use package data if installed...otherwise assume we're under the VDR source directory:
PKGCFG = $(if $(VDRDIR),$(shell pkg-config --variable=$(1) $(VDRDIR)/vdr.pc),$(shell pkg-config --variable=$(1) vdr || pkg-config --variable=$(1) ../../../vdr.pc))
LIBDIR = $(call PKGCFG,libdir)
LOCDIR = $(call PKGCFG,locdir)
PLGCONFDIR = $(call PKGCFG,configdir)/plugins/$(PLUGIN)
#
TMPDIR ?= /tmp

### The compiler options:

export CFLAGS   = $(call PKGCFG,cflags)
export CXXFLAGS = $(call PKGCFG,cxxflags)
CXXFLAGS += $(shell tntnet-config --cxxflags)

# Check for libpcre c++ wrapper

HAVE_LIBPCRECPP = $(shell pcre-config --libs-cpp)
ECPPC ?= ecppc


### The version number of VDR's plugin API:

APIVERSION = $(call PKGCFG,apiversion)

### The name of the distribution archive:

ARCHIVE = $(PLUGIN)-$(VERSION)
PACKAGE = vdr-$(ARCHIVE)

### The name of the shared object file:

SOFILE = libvdr-$(PLUGIN).so

### Includes and Defines (add further entries here):

INCLUDES += 

DEFINES	 += -DPLUGIN_NAME_I18N='"$(PLUGIN)"'
DEFINES  += -DTNTVERSION=$(TNTVERSION)

### Optional configuration features:

ifneq ($(TNTVERS7),yes)
	INCLUDES += -Ihttpd
	LIBS	 += httpd/libhttpd.a
endif

PLUGINFEATURES =
ifneq ($(HAVE_LIBPCRECPP),)
	PLUGINFEATURES += -DHAVE_LIBPCRECPP
	DEFINES        += $(PLUGINFEATURES)
	CXXFLAGS       += $(shell pcre-config --cflags)
	LIBS           += $(HAVE_LIBPCRECPP)
endif

### The object files (add further files here):

SUBDIRS	= pages css javascript
ifneq ($(TNTVERS7),yes)
	SUBDIRS += httpd
endif

OBJS = $(PLUGIN).o thread.o tntconfig.o setup.o i18n.o timers.o \
       tools.o recman.o tasks.o status.o epg_events.o epgsearch.o \
       grab.o md5.o filecache.o livefeatures.o preload.o timerconflict.o \
       users.o

LIBS += $(shell tntnet-config --libs)

WEBLIBS	   = pages/libpages.a css/libcss.a javascript/libjavascript.a

### The main target:

.PHONY: all dist clean subdirs $(SUBDIRS) PAGES

all: subdirs $(SOFILE) i18n

### Implicit rules:

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $(DEFINES) $(PLUGINFEATURES) $(INCLUDES) -o $@ $<

### Dependencies:

MAKEDEP = $(CXX) -MM -MG
DEPFILE = .dependencies
$(DEPFILE): Makefile
	@$(MAKEDEP) $(DEFINES) $(PLUGINFEATURES) $(INCLUDES) $(OBJS:%.o=%.cpp) > $@

-include $(DEPFILE)

### Internationalization (I18N):

PODIR     = po
I18Npo    = $(wildcard $(PODIR)/*.po)
I18Nmo    = $(addsuffix .mo, $(foreach file, $(I18Npo), $(basename $(file))))
I18Nmsgs  = $(addprefix $(DESTDIR)$(LOCDIR)/, $(addsuffix /LC_MESSAGES/vdr-$(PLUGIN).mo, $(notdir $(foreach file, $(I18Npo), $(basename $(file))))))
I18Npot   = $(PODIR)/$(PLUGIN).pot

%.mo: %.po
	msgfmt -c -o $@ $<

$(I18Npot): $(OBJS:%.o=%.cpp)
	xgettext -C -cTRANSLATORS --no-wrap --no-location -k -ktr -ktrNOOP --package-name=vdr-$(PLUGIN) --package-version=$(VERSION) --msgid-bugs-address=' http://live.vdr-developer.org' -o $@ $(OBJS:%.o=%.cpp) pages/*.cpp setup.h epg_events.h

%.po: $(I18Npot)
	msgmerge -U --no-wrap --no-location --backup=none -q -N $@ $<
	@touch $@

$(I18Nmsgs): $(DESTDIR)$(LOCDIR)/%/LC_MESSAGES/vdr-$(PLUGIN).mo: $(PODIR)/%.mo
	install -D -m644 $< $@

.PHONY: i18n
i18n: $(I18Nmo) $(I18Npot)

install-i18n: $(I18Nmsgs)

### Targets:

subdirs: $(SUBDIRS)

$(SUBDIRS): $(VERSIONSUFFIX)
	@echo "*** $@"
	@$(MAKE) -C $@ VDRDIR="$(shell realpath "$(VDRDIR)")" PLUGINFEATURES="$(PLUGINFEATURES)"

$(VERSIONSUFFIX):
	./buildutil/version-util $(VERSIONSUFFIX) || ./buildutil/version-util -F $(VERSIONSUFFIX)

$(SOFILE): $(VERSIONSUFFIX) $(OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -shared $(OBJS) -Wl,--whole-archive $(WEBLIBS) -Wl,--no-whole-archive $(LIBS) -o $@

ifneq ($(TNTVERS7),yes)
	@echo ""
	@echo "If LIVE was built successfully and you can try to use it!"
	@echo ""
	@echo ""
	@echo ""
	@echo ""
	@echo "IMPORTANT INFORMATION:"
	@echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	@echo "+ This is one of the *last* CVS versions of LIVE which will   +"
	@echo "+ work with versions of tntnet *less* than 1.6.0.6!           +"
	@echo "+                                                             +"
	@echo "+ This version of LIVE already supports tntnet >= 1.6.0.6.    +"
	@echo "+                                                             +"
	@echo "+ Please upgrade tntnet to at least version 1.6.0.6 soon, if  +"
	@echo "+ you want to keep track of bleeding edge LIVE development.   +"
	@echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	@echo ""
	@echo ""
	@echo ""
	@echo ""
endif

install-lib: $(SOFILE)
	install -D $^ $(DESTDIR)$(LIBDIR)/$^.$(APIVERSION)

install-resources:
	mkdir -p $(DESTDIR)$(PLGCONFDIR)
	cp -a live/* $(DESTDIR)$(PLGCONFDIR)

install: subdirs install-lib install-i18n install-resources

dist: $(I18Npo) clean
	@-rm -rf $(TMPDIR)/$(ARCHIVE)
	@mkdir $(TMPDIR)/$(ARCHIVE)
	@cp -a * $(TMPDIR)/$(ARCHIVE)
	@tar czf $(PACKAGE).tgz -C $(TMPDIR) $(ARCHIVE)
	@-rm -rf $(TMPDIR)/$(ARCHIVE)
	@echo Distribution package created as $(PACKAGE).tgz

clean: subdirs
	@-rm -f $(PODIR)/*.mo $(PODIR)/*.pot
	@-rm -f $(OBJS) $(DEPFILE) *.so *.tgz core* *~
	@-rm -f $(VERSIONSUFFIX)
