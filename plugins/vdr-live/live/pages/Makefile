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

VERSION = $(shell grep '\#define LIVEVERSION ' ../setup.h | awk '{ print $$3 }' | sed -e 's/[";]//g')
TNTVERSION ?= $(shell tntnet-config --version | sed -e's/\.//g' | sed -e's/pre.*//g' | awk '/^..$$/ { print $$1."000"} /^...$$/ { print $$1."00"} /^....$$/ { print $$1."0" } /^.....$$/ { print $$1 }')

### The directory environment:

# Use package data if installed...otherwise assume we're under the VDR source directory:
PKGCFG = $(if $(VDRDIR),$(shell pkg-config --variable=$(1) $(VDRDIR)/vdr.pc),$(shell pkg-config --variable=$(1) vdr || pkg-config --variable=$(1) ../../../../vdr.pc))
LIBDIR = $(call PKGCFG,libdir)
LOCDIR = $(call PKGCFG,locdir)
#
TMPDIR ?= /tmp

### The compiler options:

export CFLAGS   = $(call PKGCFG,cflags)
export CXXFLAGS = $(call PKGCFG,cxxflags)
TNTFLAGS ?= -Wno-overloaded-virtual -Wno-unused-variable  -Wno-unused-but-set-variable

ECPPC ?= ecppc

### The name of the library file:

ARFILE = libpages.a

### Includes and Defines (add further entries here):

INCLUDES += -I..

DEFINES ?= -DPLUGIN_NAME_I18N='"$(PLUGIN)"' -DTNTVERSION=$(TNTVERSION)

### The object files (add further files here):

OBJS	= menu.o recordings.o schedule.o multischedule.o screenshot.o   \
          timers.o whats_on.o switch_channel.o keypress.o remote.o	\
          channels_widget.o edit_timer.o error.o pageelems.o tooltip.o	\
          vlc.o searchtimers.o edit_searchtimer.o searchresults.o	\
          searchepg.o login.o ibox.o xmlresponse.o play_recording.o	\
          pause_recording.o stop_recording.o ffw_recording.o		\
          rwd_recording.o setup.o content.o epginfo.o timerconflicts.o  \
          recstream.o users.o edit_user.o edit_recording.o

### The main target:

.PHONY: all clean

all: $(ARFILE)

### Implicit rules:

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(TNTFLAGS) -c $(DEFINES) $(PLUGINFEATURES) $(INCLUDES) -o $@ $<

%.cpp: %.ecpp
	$(ECPPC) $(ECPPFLAGS) $(ECPPFLAGS_CPP) -o $@ $<

### Dependencies:

MAKEDEP = $(CXX) -MM -MG
DEPFILE = .dependencies
$(DEPFILE): Makefile $(OBJS:%.o=%.cpp) $(OBJS:%.o=%.ecpp)
	@$(MAKEDEP) $(DEFINES) $(PLUGINFEATURES) $(INCLUDES) $(OBJS:%.o=%.cpp) > $@

-include $(DEPFILE)

### Internationalization (I18N):

install-i18n:
 
### Targets:

$(ARFILE): $(OBJS)
	$(AR) r $@ $^

install-lib: $(ARFILE)

install: install-lib install-i18n

clean:
	@rm -f *~ *.o core* $(ARFILE) $(OBJS:%.o=%.cpp) $(DEPFILE)
