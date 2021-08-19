#ifndef __XMMS_TFMX_H__
#define __XMMS_TFMX_H__

#include <xmms/plugin.h>
#include <xmms/configfile.h>
#include <xmms/util.h>

#include <glib.h>
#include <gtk/gtk.h>
#include <pthread.h>

/* xmms input plugin entry point */
InputPlugin *get_iplugin_info(void);

/* global variables */
extern InputPlugin iplugin;

struct MyTFMXConfig {
    int freq;
    int loop_subsong;
    int over;
    int blend;
    int filt;
};

extern struct MyTFMXConfig plugin_cfg;

void mcp_update_info (char *filename);
void mcp_update_song_display(int song);
void mcp_update_position_display(int position);
void ChangeSubSong(char song);
gchar *main_get_info_text(char *filename);

void tfmx_cfg_load(void);
void tfmx_cfg_save(void);

#endif /* __XMMS_TFMX_H__ */

