pkglibdir = $(xmmsdir)

pkglib_LTLIBRARIES = libtfmx.la

libtfmx_la_LDFLAGS = -module -avoid-version
libtfmx_la_SOURCES = \
tfmx_audio.c tfmx_audio.h tfmx_iface.c tfmx_loader.c tfmx_player.c main.c unsqsh.c unsqsh.h \
tfmx_player.h  tfmx.h  tfmx_iface.h xmms_tfmx.h modctrlpanel.c modctrlpanel.h \
xmms_info.c xmms_about.c xmms_config.c

INCLUDES = -I$(top_srcdir)
LIBS := $(LIBS) @GTK_LIBS@
AM_CFLAGS := $(CFLAGS) @GTK_CFLAGS@

