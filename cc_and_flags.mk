_WFLAGS = -Wformat-security -Warray-bounds -Wstack-protector \
		  -Wall -Wextra -Wpedantic -Wshadow -Wvla -Wpointer-arith -Wwrite-strings \
		  -Wfloat-equal -Wcast-align -Wcast-qual \
		  -Wunreachable-code -Wundef -Werror=format-security -Werror=array-bounds \
		  -Werror=uninitialized
WGCC = -Wlogical-op -Wcast-align=strict \
	   -Wsuggest-attribute=format -Wsuggest-attribute=malloc \
	   -Wsuggest-attribute=pure -Wsuggest-attribute=const \
	   -Wsuggest-attribute=noreturn -Wsuggest-attribute=cold

WNOFLAGS=
VISIBILITY ?= -fvisibility=hidden

DCC ?= gdc
DCC_BASIC_O ?= -o
DCC_BASIC_C ?= -c
_DFLAGS =


ifeq ($(RELEASE),true)
	_COMMON_CFLAGS = -march=$(MARCH)
	D_MCPU = baseline
else
	_COMMON_CFLAGS = -march=native
	D_MCPU = native
endif
_LFLAGS  =

# detect if the user chose GCC or Clang

ifeq ($(shell $(CC) -v 2>&1 | grep -c "gcc version"), 1)
	include gcc_chosen.mk
	ifeq ($(DEBUG),true)
		# gcc-specific security/debug flags
		WGCC   += -fanalyzer
		_COMMON_CFLAGS += -ggdb
	endif #debug
	_COMMON_CFLAGS += $(_WFLAGS) $(WGCC)

else ifeq ($(shell $(CC) -v 2>&1 | grep -c "clang version"), 1)
	include clang_chosen.mk
	ifeq ($(DEBUG),true)
	# clang-specific security/debug flags
	_COMMON_CFLAGS += -fsanitize=undefined,signed-integer-overflow,null,alignment,address,leak,cfi \
				  -fsanitize-undefined-trap-on-error -ftrivial-auto-var-init=zero \
				  -mspeculative-load-hardening -mretpoline

		_LFLAGS  = -fsanitize=address
endif #debug

	_COMMON_CFLAGS += $(_WFLAGS)
	WNOFLAGS += -Wno-disabled-macro-expansion
endif #compiler


ifeq ($(DEBUG),true)
	# generic security/debug flags
	_COMMON_CFLAGS += -Og -D_DEBUG -fno-builtin
	_LFLAGS += -Wl,-z,relro,-z,noexecstack
	_DFLAGS += -g
endif # DEBUG
ifeq ($(RELEASE),true)
	_COMMON_CFLAGS += -fstack-clash-protection -D_FORTIFY_SOURCE=2 -fcf-protection \
			  -Werror=format-security
	_LFLAGS += -fPIE -fPIC
endif


# Flags every compile will need
_COMMON_CFLAGS += $(COMMON_FLAGS) $(COMMON_FLAGS_C) -D_PACKAGE_NAME=\"$(PACKAGE_NAME)\" \
				 -D_PACKAGE_VERSION=\"$(PACKAGE_VERSION)\" \
		  $(VISIBILITY) $(WNOFLAGS) -D_POSIX_C_SOURCE=200809L
_CXXFLAGS = $(_COMMON_CFLAGS) -std=$(CXX_STD) $(CXXFLAGS)
_CFLAGS = $(_COMMON_CFLAGS) -std=$(C_STD) $(CFLAGS)
_LFLAGS += -L/usr/local/lib $(LDFLAGS)
ifneq ($(DCC), gdc)
	DCC_BASIC_O = -of=
	_DFLAGS += -O -mcpu=$(D_MCPU) $(DFLAGS)
	_LD_DFLAGS = -L-lphobos2 -L-lstdc++
  ifeq ($(DCC),dmd)
    ifeq ($(CC),gcc)
	_CFLAGS += $(LTO)
	_CXXFLAGS += $(LTO)
    endif # if gcc
  else # is ldc
    ifeq ($(CC),clang)
	_CFLAGS += $(LTO)
	_CXXFLAGS += $(LTO)
    endif # if clang
  endif # if dmd/ldc
else
  ifeq ($(CC),gcc)
	_CFLAGS += $(LTO)
	_CXXFLAGS += $(LTO)
  endif
	_DFLAGS += $(COMMON_FLAGS) -march=$(MARCH) $(DFLAGS)
	_LD_DFLAGS = -lstdc++
	GDC_XD = -xd
endif # if gdc
