/* Here I try to do a little song/position panel ...
 */

/*
 * 6-Mar-2000 : trying to fix/hide inconsistencies before
 * first release ...
 */

#include <gtk/gtk.h>
#include "modctrlpanel.h"

enum {
    POSITION_CHANGED,
    SONG_CHANGED,
    LAST_SIGNAL
};

static void modctrlpanel_class_init          (ModCtrlPanelClass *klass);
static void modctrlpanel_init                (ModCtrlPanel      *mcp);

static gint modctrlpanel_signals[LAST_SIGNAL];
static GtkWindowClass *parent_class = NULL;

static char *position_label_text = NULL;
static char *song_label_text = NULL;


static void
modctrlpanel_destroy (GtkObject *object);
static void 
modctrlpanel_prev_song (GtkWidget *widget, ModCtrlPanel *mcp);
static void
modctrlpanel_next_song (GtkWidget *widget, ModCtrlPanel *mcp);
static void 
modctrlpanel_prev_position (GtkWidget *widget, ModCtrlPanel *mcp);
static void 
modctrlpanel_next_position (GtkWidget *widget, ModCtrlPanel *mcp);


/**************************/
/*  Function definitions  */

guint
modctrlpanel_get_type()
{
  static guint type = 0;
  if (!type)
  {
    static const GtkTypeInfo info =
    {
      "ModCtrlPanel",
      sizeof (ModCtrlPanel),
      sizeof (ModCtrlPanelClass),
      (GtkClassInitFunc) modctrlpanel_class_init,
      (GtkObjectInitFunc) modctrlpanel_init,
      NULL, NULL
    };
    type = gtk_type_unique (GTK_TYPE_WINDOW, &info);
  }
  return type;
}

static void
modctrlpanel_class_init (ModCtrlPanelClass *class)
{
    GtkObjectClass *object_class;

    object_class = (GtkObjectClass*) class;
    parent_class = gtk_type_class (GTK_TYPE_WINDOW);
    object_class->destroy = modctrlpanel_destroy;

    modctrlpanel_signals[POSITION_CHANGED] =
	gtk_signal_new ("position_changed",
			GTK_RUN_FIRST,
			object_class->type,
			GTK_SIGNAL_OFFSET (ModCtrlPanelClass, position_changed),
			gtk_marshal_NONE__INT, GTK_TYPE_NONE, 1,
			GTK_TYPE_INT);
    modctrlpanel_signals[SONG_CHANGED] =
	gtk_signal_new ("song_changed",
			GTK_RUN_FIRST,
			object_class->type,
			GTK_SIGNAL_OFFSET (ModCtrlPanelClass, song_changed),
			gtk_marshal_NONE__INT, GTK_TYPE_NONE, 1,
			GTK_TYPE_INT);


    gtk_object_class_add_signals (object_class, modctrlpanel_signals, LAST_SIGNAL);

    class->position_changed = NULL;
    class->song_changed = NULL;
}


static void
modctrlpanel_init (ModCtrlPanel *mcp)
{
    GtkWidget *buttons_hbox;
    GtkWidget *scrolled_win;
    GtkWidget *align_buttons;

    mcp->main_vbox = gtk_vbox_new (FALSE, 10);
    gtk_container_set_border_width (GTK_CONTAINER (mcp), 10);
    gtk_container_add (GTK_CONTAINER (mcp), mcp->main_vbox);

    /* create a scrolled window for info text */
    scrolled_win = gtk_scrolled_window_new (NULL, NULL);
    gtk_scrolled_window_set_policy (GTK_SCROLLED_WINDOW (scrolled_win),
				    GTK_POLICY_AUTOMATIC,
				    GTK_POLICY_AUTOMATIC);
    gtk_box_pack_start(GTK_BOX(mcp->main_vbox), scrolled_win, TRUE, TRUE, 0);

    mcp->text = gtk_text_new(NULL, NULL);
    gtk_text_set_editable(GTK_TEXT(mcp->text), FALSE);

    gtk_container_add(GTK_CONTAINER(scrolled_win), mcp->text);
/*      gtk_widget_set_usize(mcp->text, 300, 100); */
    
/*
 * don't show the position/song as long as it's buggy, to not
 * confuse users (but feel free to hack on this - though I guess
 * it would require better interaction with xmms)
 */

    mcp->label_position = gtk_label_new(NULL);
    gtk_box_pack_start (GTK_BOX (mcp->main_vbox), mcp->label_position, FALSE, FALSE, 0);

    mcp->label_song = gtk_label_new(NULL);
    gtk_box_pack_start (GTK_BOX (mcp->main_vbox), mcp->label_song, FALSE, FALSE, 0);

    buttons_hbox = gtk_hbox_new (TRUE, 5);
    gtk_box_pack_start (GTK_BOX (mcp->main_vbox), buttons_hbox, FALSE, FALSE, 0);

    mcp->next_song_button = gtk_button_new_with_label("Next Song");
    mcp->prev_song_button = gtk_button_new_with_label("Prev Song");
    mcp->next_position_button = gtk_button_new_with_label("Next Position");
    mcp->prev_position_button = gtk_button_new_with_label("Prev Position");

    gtk_signal_connect (GTK_OBJECT (mcp->next_song_button), "clicked",
		      (GtkSignalFunc) modctrlpanel_next_song, 
		      (gpointer) mcp);
    gtk_signal_connect (GTK_OBJECT (mcp->prev_song_button), "clicked",
		      (GtkSignalFunc) modctrlpanel_prev_song, 
		      (gpointer) mcp);
    gtk_signal_connect (GTK_OBJECT (mcp->next_position_button), "clicked",
		      (GtkSignalFunc) modctrlpanel_next_position, 
		      (gpointer) mcp);
    gtk_signal_connect (GTK_OBJECT (mcp->prev_position_button), "clicked",
		      (GtkSignalFunc) modctrlpanel_prev_position, 
		      (gpointer) mcp);

    gtk_box_pack_start (GTK_BOX (buttons_hbox), mcp->prev_song_button, FALSE, FALSE, 0);
    gtk_box_pack_start (GTK_BOX (buttons_hbox), mcp->prev_position_button, FALSE, FALSE, 0);
    gtk_box_pack_start (GTK_BOX (buttons_hbox), mcp->next_position_button, FALSE, FALSE, 0);
    gtk_box_pack_start (GTK_BOX (buttons_hbox), mcp->next_song_button, FALSE, FALSE, 0);

    gtk_widget_show_all(GTK_WIDGET(mcp));
}


GtkWidget*
modctrlpanel_new ()
{
    ModCtrlPanel *mcp;

    mcp = gtk_type_new (modctrlpanel_get_type ());
    mcp->current_position = 0;
    mcp->current_song = 0;
    mcp->max_position = 0;
    mcp->max_song = 0;
    return GTK_WIDGET (mcp);
}

/*
 * position : new position to display. If -1, redisplay current
 * position.
 */
void 
modctrlpanel_set_position (ModCtrlPanel *mcp, int position)
{
    if (position_label_text)
    {
	g_free(position_label_text);
/*  	    g_print("free string %p\n", position_label_text); */
    }
    if (position != -1)
	mcp->current_position = position;
    position_label_text = g_strdup_printf("Position : %d / %d",
					  mcp->current_position,
					  mcp->max_position);
/*  	g_print("allocated string %p\n", position_label_text); */
    gtk_label_set_text(GTK_LABEL(mcp->label_position), position_label_text);
    gtk_widget_show(mcp->label_position);
}

void 
modctrlpanel_set_song (ModCtrlPanel *mcp, int song)
{
    if (song_label_text)
	g_free(song_label_text);
    mcp->current_song = song;
    song_label_text = g_strdup_printf("Song : %d / %d",
				      mcp->current_song,
				      mcp->max_song);
    gtk_label_set_text(GTK_LABEL(mcp->label_song), song_label_text);
    gtk_widget_show(mcp->label_song);
}


void 
modctrlpanel_set_max_position (ModCtrlPanel *mcp, int maxposition)
{
    mcp->max_position = maxposition;
}

void 
modctrlpanel_set_max_song (ModCtrlPanel *mcp, int maxsong)
{

    mcp->max_song = maxsong;
}


static void 
modctrlpanel_prev_song (GtkWidget *widget, ModCtrlPanel *mcp)
{
    if (mcp->current_song > 0)
    {
	modctrlpanel_set_song(mcp, mcp->current_song - 1);
	gtk_signal_emit (GTK_OBJECT (mcp), 
			 modctrlpanel_signals[SONG_CHANGED], mcp->current_song);
    }
}

static void
modctrlpanel_next_song (GtkWidget *widget, ModCtrlPanel *mcp)
{
    if (mcp->current_song < mcp->max_song)
    {
	modctrlpanel_set_song(mcp, mcp->current_song + 1);
	gtk_signal_emit (GTK_OBJECT (mcp), 
			 modctrlpanel_signals[SONG_CHANGED], mcp->current_song);
    }
}

static void 
modctrlpanel_prev_position (GtkWidget *widget, ModCtrlPanel *mcp)
{
    if (mcp->current_position > 0)
    {
	modctrlpanel_set_position(mcp, mcp->current_position - 1);
	gtk_signal_emit (GTK_OBJECT (mcp),
			 modctrlpanel_signals[POSITION_CHANGED], mcp->current_song);
    }
}


static void 
modctrlpanel_next_position (GtkWidget *widget, ModCtrlPanel *mcp)
{
    if (mcp->current_position < mcp->max_position)
    {
	modctrlpanel_set_position(mcp, mcp->current_position + 1);
	gtk_signal_emit (GTK_OBJECT (mcp), 
			 modctrlpanel_signals[POSITION_CHANGED], mcp->current_song);
    }
}


static void
modctrlpanel_destroy (GtkObject *object)
{
  ModCtrlPanel *mcp;

  g_return_if_fail (object != NULL);
  g_return_if_fail (IS_MODCTRLPANEL (object));

  mcp = MODCTRLPANEL (object);

  if (song_label_text)
  {
      g_free(song_label_text);
      song_label_text = NULL;
  }
  if (position_label_text)
  {
      g_free(position_label_text);
      position_label_text = NULL;
  }
  if (GTK_OBJECT_CLASS (parent_class)->destroy)
    (* GTK_OBJECT_CLASS (parent_class)->destroy) (object);
}

void 
modctrlpanel_set_info_text (ModCtrlPanel *mcp, const gchar *s)
{
    gtk_text_freeze (GTK_TEXT(mcp->text));
    gtk_text_set_point(GTK_TEXT(mcp->text), 0);
    gtk_text_forward_delete (GTK_TEXT(mcp->text),
			     gtk_text_get_length(GTK_TEXT(mcp->text)));
    gtk_text_insert(GTK_TEXT(mcp->text), NULL, NULL, NULL, s, -1);
    gtk_text_thaw (GTK_TEXT(mcp->text));
    gtk_widget_show(mcp->text);
}

void 
modctrlpanel_position_buttons_set_sensitive (ModCtrlPanel *mcp, gboolean flag)
{
    gtk_widget_set_sensitive(GTK_WIDGET(mcp->next_position_button), flag);
    gtk_widget_set_sensitive(GTK_WIDGET(mcp->prev_position_button), flag);
}

void 
modctrlpanel_song_buttons_set_sensitive (ModCtrlPanel *mcp, gboolean flag)
{
    gtk_widget_set_sensitive(GTK_WIDGET(mcp->next_song_button), flag);
    gtk_widget_set_sensitive(GTK_WIDGET(mcp->prev_song_button), flag);
}

