AM_CPPFLAGS = $(YAMFE_CFLAGS)

bin_PROGRAMS = yamfe

yamfe_SOURCES = yamfe.vala screen.vala input.vala splash-screen.vala selection-screen.vala
yamfe_LDADD = $(YAMFE_LIBS)
yamfe_VALAFLAGS = --pkg=clutter-1.0 --pkg=gdk-pixbuf-2.0 --pkg=gmodule-2.0

CLEANFILES = *.h *.c *.vapi *.stamp