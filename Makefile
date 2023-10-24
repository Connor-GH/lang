# variables defined for "cc_and_flags" API
PACKAGE_NAME_NOTSTRING = lang parser
PACKAGE_NAME = "$(PACKAGE_NAME_NOTSTRING)"
TARGET = lang
PACKAGE_VERSION = 0.0.1
C_STD ?= c11
CXX_STD ?= c++11
# setting up sources
SRCDIR = $(shell pwd)/src
OBJDIR = $(shell pwd)/obj
BINDIR = $(shell pwd)/bin
SRCDIR_FRONTEND = $(SRCDIR)/frontend
SRCDIR_BACKEND_ = $(SRCDIR)/backend
SRCDIR_LIBLANG = $(SRCDIR)/liblang
INCLUDES = $(wildcard $(SRCDIR)/include/*.h)
LANG_NAME = $(TARGET)
# parsing/frontend
SOURCES_C_FRONTEND = $(wildcard $(SRCDIR_FRONTEND)/*.c)
OBJECTS_C_FRONTEND = $(SOURCES_C_FRONTEND:$(SRCDIR_FRONTEND)/%.c=$(OBJDIR)/%.o)
SOURCES_CXX_FRONTEND = $(wildcard $(SRCDIR_FRONTEND)/*.cpp)
OBJECTS_CXX_FRONTEND = $(SOURCES_CXX_FRONTEND:$(SRCDIR_FRONTEND)/%.cpp=$(OBJDIR)/%.o)

SOURCES_D_DRIVER = $(wildcard $(SRCDIR)/*.d)
OBJECTS_D_DRIVER = $(SOURCES_D_DRIVER:$(SRCDIR)/%.d=$(OBJDIR)/%.o)
SOURCES_D_FRONTEND = $(wildcard $(SRCDIR_FRONTEND)/*.d)
OBJECTS_D_FRONTEND = $(SOURCES_D_FRONTEND:$(SRCDIR_FRONTEND)/%.d=$(OBJDIR)/%.o)

TARGET_ARCH ?= x86
ifeq ($(TARGET_ARCH), x86)
	MARCH = x86-64
endif
SRCDIR_BACKEND = $(SRCDIR_BACKEND_)/arch/$(TARGET_ARCH)

SOURCES_CXX_LIBLANG = $(wildcard $(SRCDIR_LIBLANG)/*.cpp)
OBJECTS_CXX_LIBLANG = $(SOURCES_CXX_LIBLANG:$(SRCDIR_LIBLANG)/%.cpp=$(OBJDIR)/%.o)

SOURCES_C = $(SOURCES_C_FRONTEND)
OBJECTS_C = $(OBJECTS_C_FRONTEND)
SOURCES_CXX = $(SOURCES_CXX_FRONTEND) $(SOURCES_CXX_LIBLANG)
OBJECTS_CXX = $(OBJECTS_CXX_FRONTEND) $(OBJECTS_CXX_LIBLANG)
SOURCES_D = $(SOURCES_D_DRIVER) $(SOURCES_D_FRONTEND)
OBJECTS_D = $(OBJECTS_D_DRIVER) $(OBJECTS_D_FRONTEND)


IVARS = -I$(SRCDIR)/include -I$(SRCDIR_FRONTEND)/include -I$(SRCDIR_BACKEND)/include -I$(SRCDIR)
IVARS += -I$(SRCDIR_FRONTEND)

COMMON_FLAGS = -O2 -pipe $(IVARS)
COMMON_FLAGS_C = -DLANGNAME_STRING=\"$(LANG_NAME)\"
include cc_and_flags.mk
the_CFLAGS = -pedantic $(_CFLAGS)
the_CXXFLAGS = -Wno-c++98-compat -fno-rtti $(_CXXFLAGS)
the_LFLAGS = $(LDFLAGS) $(IVARS) $(_LFLAGS)
the_CXX_LFLAGS = $(the_LFLAGS)
the_DFLAGS = $(IVARS) $(_DFLAGS)
the_D_LFLAGS = $(_LD_DFLAGS)

.PHONY: all clean remove

all:
	$(MAKE) remove
	$(MAKE) driver
	$(MAKE) $(TARGET)



$(TARGET): $(OBJECTS_C) $(OBJECTS_CXX) $(OBJECTS_D) | $(BINDIR)
	$(DCC) $(DCC_BASIC_O)$(BINDIR)/$@ $^ $(IVARS) $(the_D_LFLAGS)

driver:
	sed $(SRCDIR)/cc.d -e 's/{{\[sed_version\]}}/$(PACKAGE_VERSION)/g' -e \
		's/{{\[sed_name\]}}/$(PACKAGE_NAME_NOTSTRING)/g' | $(DCC) $(GDC_XD) - \
		$(DCC_BASIC_C) $(DCC_BASIC_O)$(OBJDIR)/cc.o $(the_DFLAGS)

tools:
	export DCC="$(DCC)"; export CC="$(CC)"; export DCC_BASIC_O="$(DCC_BASIC_O)"; \
		export the_DFLAGS='$(the_DFLAGS)'; export the_CFLAGS='$(the_CFLAGS)'; \
		export BINDIR="$(BINDIR)"; cd tests/tools; $(MAKE)
$(OBJDIR)/%.o : $(SRCDIR)/%.d | $(OBJDIR)
	$(DCC) $(DCC_BASIC_O)$@ $(the_DFLAGS) $^ $(DCC_BASIC_C)

$(OBJDIR)/%.o : $(SRCDIR_FRONTEND)/%.c | $(OBJDIR)
	$(CC) -o $@ $(the_CFLAGS) $^ -c

$(OBJDIR)/%.o : $(SRCDIR_FRONTEND)/%.cpp | $(OBJDIR)
	$(CXX) -o $@ $(the_CXXFLAGS) $^ -c

$(OBJDIR)/%.o : $(SRCDIR_LIBLANG)/%.cpp | $(OBJDIR)
	$(CXX) -o $@ $(the_CXXFLAGS) $^ -c

$(OBJDIR)/%.o : $(SRCDIR_FRONTEND)/%.d | $(OBJDIR)
	$(DCC) $(DCC_BASIC_O)$@ $(the_DFLAGS) $^ $(DCC_BASIC_C)

$(BINDIR) $(OBJDIR):
	mkdir -p $@

clean:
	rm -rf $(OBJECTS_C) $(OBJECTS_CXX) $(OBJECTS_D)

remove: clean
	rm -rf $(BINDIR)/$(TARGET)

