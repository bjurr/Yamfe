AC_PREREQ([2.65])
AC_INIT([yamfe],[1.0],[dbureau@gmail.com])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE
AM_INIT_AUTOMAKE([foreign])
AC_CONFIG_FILES([Makefile
        src/Makefile])

LT_INIT
AC_PROG_CC
AM_PROG_VALAC

pkg_modules="clutter-1.0 >= 1.16.0
             cogl-1.0 >= 1.16.0
             glib-2.0 >= 2.31.19
             json-glib-1.0 >= 0.12.0
             gobject-2.0 >= 2.31.19
             gmodule-2.0 >= 2.31.19
             gdk-pixbuf-2.0 >= 2.30.4"
PKG_CHECK_MODULES(YAMFE, [$pkg_modules])
AC_SUBST(YAMFE_CFLAGS)
AC_SUBST(YAMFE_LIBS)

AC_OUTPUT
