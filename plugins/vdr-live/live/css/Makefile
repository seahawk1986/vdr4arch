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
TNTFLAGS ?= -Wno-overloaded-virtual -Wno-unused-function

ECPPC ?= ecppc

### The name of the library file:

ARFILE = libcss.a

### Includes and Defines (add further entries here):

INCLUDES += -I..

DEFINES ?= -DPLUGIN_NAME_I18N='"$(PLUGIN)"' -DTNTVERSION=$(TNTVERSION)

### The object files (add further files here):

OBJS = styles.o

### The main target:

.PHONY: all clean

all: $(ARFILE)

### Implicit rules:

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(TNTFLAGS) -c $(DEFINES) $(PLUGINFEATURES) $(INCLUDES) -o $@ $<

%.cpp: %.css
	$(ECPPC) $(ECPPFLAGS) $(ECPPFLAGS_CSS) -b -m "text/css" -o $@ $<

### Internationalization (I18N):

install-i18n:
 
### Targets:

$(ARFILE): $(OBJS)
	$(AR) r $@ $^

install-lib: $(ARFILE)

install: install-lib install-i18n

clean:
	@rm -f *~ *.o core* $(ARFILE) $(OBJS:%.o=%.cpp)
