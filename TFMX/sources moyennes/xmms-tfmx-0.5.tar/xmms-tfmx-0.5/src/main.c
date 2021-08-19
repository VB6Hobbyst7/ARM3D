/* 
 * This is a mess, inherited from those TFMX c0d3rZ dUdeZ :)
 * Help me, I'm under bad influence !
 */

#include <stdlib.h>
#include <string.h>
#include "xmms_tfmx.h"
#include "tfmx_iface.h"
#include "tfmx_player.h"

struct MyTFMXConfig plugin_cfg;          /* hold some config infos */

static char lastfn[1000];                /* a filename buffer */
static unsigned char *sample_buffer = 0; /* the block to output */
static char moduleInfo[2000];            /* module info as a big string */
static int  channels = 2;                /* number of output channels */
static gboolean killDecodeThread = 0;    /* flag to stop thread */
static gboolean paused = FALSE;          /* playback is paused */
static gboolean playing;                 /* plugin is currently playing */
static int current_pos;                  /* current position played */
static int current_subsong;              /* current subsong played */
static gboolean audio_opened;            /* xmms audio is currently opened */
static gboolean audio_failed;            /* failure encountered opening xmms audio */
static gboolean play_failed;             /* playing init failed */
static	pthread_t decode_thread;

static void *ThreadEntry(void* pArg);

/* xmms symbol */
InputPlugin *get_iplugin_info(void)
{
    return &iplugin;
}

static void ip_init(void)
{
    playing = FALSE;
    plugin_cfg.freq = 44100;
    plugin_cfg.loop_subsong = 0;
    plugin_cfg.over = 0;
    plugin_cfg.blend = 0;
    plugin_cfg.filt = 0;
    tfmx_cfg_load();
}

static int ip_is_our_file(char *filename)
{
    int res;
    res = IsTFMXFilename(filename);
    return res;
}

static void ip_get_song_info(char *filename, char **title_real, int *len_real)
{
    // without the 2 following lines, crashed !!!
    *len_real = -1;
    *title_real = NULL;
}

void quit() /* Called when WinAMP is shutting down */
{
/*  	CloseTFMXDialog(); */
    TFMXQuit();
    if(sample_buffer)
    {
	free(sample_buffer);
	sample_buffer = 0;
    }
}

int InitBuffers()
{
    if(sample_buffer)
	return 1;	/* Already allocated! */

    sample_buffer = (unsigned char *)malloc(tfmx_get_block_size() * 2);
    if(!sample_buffer)
    {
	TFMXError("Ouch! Couldn't alloc samplebuffer!");
	return 0;
    }

    return 1;
}

static void ip_play_file(char *fn)
{
    current_pos = 0;
    current_subsong = 0;

    audio_failed = FALSE;
    play_failed = FALSE;
    if(!InitBuffers())
    {
	play_failed = TRUE;
	return;	/* Allocate space for mixing, etc. */
    }
    paused = TRUE;

    memset(sample_buffer,0,tfmx_get_block_size() * 2);

    if(!lastfn || strcmp(lastfn,fn) != 0)
    {
	/*MessageBox(NULL, "Loading module...", "TFMX Plugin", MB_OK); */
	if(LoadTFMXFile(fn) != 0)
	{
	    play_failed = TRUE;
/*  	    g_print("loading failed\n"); */
	    return;
	}
	strcpy(lastfn,fn);
	TFMXSetSubSong(0);
/*  	SetSongBarRange(TFMXGetSubSongs()); */

/*  	Update song info */
	mcp_update_info(fn);
	
/*  	g_print(moduleInfo); */
    }

    TFMXRewind();

    iplugin.set_info((char *) strrchr(fn, '/') + 1,
		     0, 10000 * (player_TFMXVoices() & 7),
		     44100, channels);
    if (iplugin.output->open_audio(FMT_S16_LE,
				   44100,
				   channels) == 0)
    {
	audio_failed = TRUE;
	return;
    }
    audio_opened = TRUE;

    killDecodeThread = FALSE;
    pthread_create(&decode_thread, NULL, ThreadEntry, NULL);
    paused = FALSE;
    playing = TRUE;
}

static void ip_do_pause(short p)
{
    paused = p;
    iplugin.output->pause(p);
}

static void ip_stop(void)
{
    if (!playing)
	return;
    playing = FALSE;
    killDecodeThread = TRUE;
    while(killDecodeThread)
	xmms_usleep(10000);
    pthread_join(decode_thread, NULL);

    TFMXStop();

    /* Only flush if previously played. */
    if(lastfn && *lastfn != '\0')
	iplugin.output->flush(0);

    if (iplugin.output && audio_opened)
    {
	iplugin.output->close_audio();
	audio_opened = FALSE;
    }
}

static void ip_seek(int time)
{
/*      g_print("ip_seek\n"); */
}

static int ip_get_time(void)
{
    if (audio_failed)
	return -2;

    if (play_failed)
    {
/*  	g_print("play failed\n"); */
	return -1;
    }
    if (pdb.CurrPos != current_pos)
    {
	mcp_update_position_display(pdb.CurrPos);
    }

    if (current_pos > pdb.CurrPos)
    {
	current_pos = pdb.CurrPos;
	if (!plugin_cfg.loop_subsong)
	{
	    current_subsong++;
	    if (current_subsong > TFMXGetSubSongs())
		return -1;
    g_print("ip_get_time : ChangeSubSong %d\n", current_subsong);
	    ChangeSubSong(current_subsong);
	}
    }
    current_pos = pdb.CurrPos;
    if (iplugin.output)
	return iplugin.output->output_time();
    else
	return 0;
}

int infoDlg(char *fn, void *hwnd)
{
    /* Update song info to assert up-to-date info if play() hasn't run. */
    tfmx_fill_module_info(moduleInfo);

    /* Set pointer to info string */
/*      SetDialogInfoBox(moduleInfo); */

    /* Will only open if not open already */
/*      OpenTFMXDialog(plugInstance, hwnd); */
/*      SetDialogSongNumber(TFMXGetSubSong()); */

    /* MessageBox(NULL, info, "TFMXPlay WinAMP Plugin by Per Lindén", 0); */
    return 0;
}

gchar *
main_get_info_text(char *filename)
{
    tfmx_fill_module_info(moduleInfo);
    return moduleInfo;
}

void ChangeSubSong(char song)
{
    gboolean oldPause = paused;
    paused = TRUE;

    iplugin.output->flush(0);
    memset(sample_buffer,0,tfmx_get_block_size() * 2);

    if(song>=0 && song<TFMXGetSubSongs()) {
	g_print("TFMXSetSubSong %d\n", song);
	TFMXSetSubSong(song);
    }

    paused = oldPause;
}

void play_tick (void)
{
    long blocksize = tfmx_get_block_size();

    if (tfmx_try_to_make_block() >= 0)
    {	
	/* Get a new buffer of wave data from the module player */
	tfmx_get_block(sample_buffer);

	/* Supply vis data */
	iplugin.add_vis_pcm(iplugin.output->written_time(), FMT_S16_LE,
			    channels, blocksize, sample_buffer);

	/* Write it to the output plugin */
	while(iplugin.output->buffer_free() < blocksize)
	    xmms_usleep(10000);
	iplugin.output->write_audio(sample_buffer, blocksize);
    }
}

void *ThreadEntry(void* pArg)
{
    while (killDecodeThread == FALSE) 
    {
	if (playing)
	{
	    play_tick();
	}
	xmms_usleep(5000);
    }
    /* now that killDecodeThread is TRUE, signal that we reached here ... */
    killDecodeThread = FALSE;
    return 0;
}

extern void ip_file_info_box(char *filename);
extern void ip_configure(void);
extern void ip_about(void);

InputPlugin iplugin =
{
    NULL,
    NULL,
    "TFMX Player " VERSION,
    ip_init,
    ip_about,
    ip_configure,
    ip_is_our_file,
    NULL,
    ip_play_file,
    ip_stop,
    ip_do_pause,
    ip_seek,
    NULL,
    ip_get_time,
    NULL, NULL,
    NULL, NULL, NULL, NULL, NULL,
    ip_get_song_info,
    ip_file_info_box,	/* file_info_box */
    NULL
};


