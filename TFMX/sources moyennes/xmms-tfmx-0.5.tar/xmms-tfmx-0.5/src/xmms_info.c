#include "modctrlpanel.h"
#include "xmms_tfmx.h"
#include "tfmx.h"

static GtkWidget *mcp;

/* called when user click on buttons */
static void
song_changed (GtkWidget *mcp, int song, gpointer data)
{
/*      g_print("song_changed: ChangeSubSong %d\n", song); */
    ChangeSubSong(song);
}

void ip_file_info_box(char *filename)
{
    if (!mcp)
    {
	mcp = modctrlpanel_new();
	gtk_signal_connect(GTK_OBJECT(mcp), "destroy", GTK_SIGNAL_FUNC(gtk_widget_destroyed),
			   &mcp);
	gtk_signal_connect(GTK_OBJECT (mcp), "song_changed",
			   (GtkSignalFunc)song_changed,
			   NULL);

	modctrlpanel_position_buttons_set_sensitive(MODCTRLPANEL(mcp), FALSE);

    }
    mcp_update_info(filename);
    gtk_widget_show(mcp);
}

void mcp_update_info (char *filename)
{
    if (mcp)
    {
/*  	g_print("mcp_update_info: msn=%d mpo=%d sn=%d\n", */
/*  	       TFMXGetSubSongs() - 1, */
/*  	       num_ts, */
/*  	       TFMXGetSubSong()); */
	modctrlpanel_set_max_song(MODCTRLPANEL(mcp), TFMXGetSubSongs() - 1);
	modctrlpanel_set_max_position(MODCTRLPANEL(mcp), num_ts);
	modctrlpanel_set_position(MODCTRLPANEL(mcp), -1);
	modctrlpanel_set_song(MODCTRLPANEL(mcp), TFMXGetSubSong());
	modctrlpanel_set_info_text(MODCTRLPANEL(mcp), main_get_info_text(filename));
    }
}

void mcp_update_song_display(int song)
{
    if (mcp)
    {
/*  	modctrlpanel_set_max_song(MODCTRLPANEL(mcp), TFMXGetSubSongs() - 1); */
	modctrlpanel_set_song(MODCTRLPANEL(mcp), song);
    }
}

void mcp_update_position_display(int position)
{
    if (mcp)
	modctrlpanel_set_position(MODCTRLPANEL(mcp), position);
}


