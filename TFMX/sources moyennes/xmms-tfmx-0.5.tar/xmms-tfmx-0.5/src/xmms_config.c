#include <gtk/gtk.h>
#include "xmms_tfmx.h"

static struct MyTFMXConfig backup_options;
static GtkWidget *dialog = NULL;

/*
 * restore original options
 */
static void
configure_cancel_cb(GtkWidget *w, gpointer data)
{
	plugin_cfg = backup_options;
	gtk_widget_destroy(dialog);
}

/*
 * keep & save options
 */
static void
configure_ok_cb(GtkWidget *w, gpointer data)
{ 
	tfmx_cfg_save();
	gtk_widget_destroy(dialog);
}


/*
 * Create an horiz box with label and scale
 */
static GtkWidget *
labelled_scale_new (const char *title, GtkAdjustment *adj, gboolean isInteger)
{
	GtkWidget *hgroup;
	GtkWidget *label;
	GtkWidget *scale;

	hgroup = gtk_hbox_new(FALSE, 2);

	label = gtk_label_new(title);
	gtk_box_pack_start(GTK_BOX(hgroup), label,
			   TRUE, TRUE, 2);

	scale = gtk_hscale_new(adj);
	gtk_box_pack_start(GTK_BOX(hgroup), scale,
			   TRUE, TRUE, 2);
	if (isInteger)
		gtk_scale_set_digits(GTK_SCALE(scale), 0);

	return hgroup;
}


/*
 * to modify an integer variable whenever an adjustment change.
 */
static void
intval_changed_cb (GtkAdjustment *adj, gpointer valptr)
{
	*(gint *)valptr = adj->value;
}

/*
 * to modify a float variable whenever an adjustment change.
 */
static void
floatval_changed_cb (GtkAdjustment *adj, gpointer valptr)
{
	*(gfloat *)valptr = adj->value;
}


/*
 * to modify a boolean variable whenever a button is toggled.
 */
static void
toggled_cb (GtkToggleButton *bt, gpointer valptr)
{
	*(gboolean *)valptr = bt->active;
}

static void 
new_config_check_button (GtkWidget *box, const char *title, gboolean *ptr)
{
	GtkWidget *w ;
	w = gtk_check_button_new_with_label(title);
	gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(w),*ptr);
	gtk_signal_connect(GTK_OBJECT(w), "toggled",
			   GTK_SIGNAL_FUNC(toggled_cb), ptr);
	gtk_box_pack_start(GTK_BOX(box), w, TRUE, TRUE, 5);
}

static gboolean
init_dialog (GtkWidget *dialog)
{
    GtkWidget *dialog_vbox1;
    GtkWidget *hbox1, *filter_cm; 
    GtkAdjustment *filter_adj;

    dialog_vbox1 = GTK_DIALOG(dialog)->vbox;
    gtk_container_border_width(GTK_CONTAINER(dialog_vbox1), 5);
    hbox1 = gtk_hbox_new(FALSE, 0);
    gtk_box_pack_start(GTK_BOX(dialog_vbox1), hbox1, TRUE, TRUE, 0);
    gtk_container_border_width(GTK_CONTAINER(hbox1), 5);

    new_config_check_button(dialog_vbox1,
			    "Oversample (linear interpolation)",
			    &plugin_cfg.over);

    new_config_check_button(dialog_vbox1,
			    "Stereo blend (headphone)",
			    &plugin_cfg.blend);

    new_config_check_button(dialog_vbox1,
			    "Loop subsongs",
			    &plugin_cfg.loop_subsong);

    filter_adj = gtk_adjustment_new ( plugin_cfg.filt, 0, 4, 1, 1, 1 ) ;
    filter_cm = labelled_scale_new ("Lowpass filter", filter_adj, TRUE);
    gtk_signal_connect(GTK_OBJECT(filter_adj), "value_changed",
		       GTK_SIGNAL_FUNC(intval_changed_cb), &plugin_cfg.filt);
    gtk_box_pack_start(GTK_BOX(dialog_vbox1), filter_cm, TRUE, TRUE, 5);

    return TRUE;
}

void 
ip_configure(void)
{
    if (!dialog)
    {
	GtkWidget *ok_bt, *cancel_bt;

	backup_options = plugin_cfg;
	dialog = gtk_dialog_new();
	gtk_window_set_title(GTK_WINDOW(dialog), "TFMX plugin configuration");
	gtk_window_set_policy(GTK_WINDOW(dialog), FALSE, FALSE, FALSE);
	gtk_window_set_position(GTK_WINDOW(dialog), GTK_WIN_POS_MOUSE);
	gtk_signal_connect(GTK_OBJECT(dialog), "destroy",
			   GTK_SIGNAL_FUNC(gtk_widget_destroyed), &dialog);
	gtk_container_border_width(GTK_CONTAINER(dialog), 10);

	init_dialog(dialog);

	/* dialog buttons */
	ok_bt = gtk_button_new_with_label("Ok");
	gtk_signal_connect(GTK_OBJECT(ok_bt), "clicked",
			   GTK_SIGNAL_FUNC(configure_ok_cb), NULL);
	gtk_box_pack_start(GTK_BOX(GTK_DIALOG(dialog)->action_area), ok_bt,
			   TRUE, TRUE, 0);

	cancel_bt = gtk_button_new_with_label("Cancel");
	gtk_signal_connect(GTK_OBJECT(cancel_bt), "clicked",
			   GTK_SIGNAL_FUNC(configure_cancel_cb), NULL);
	gtk_box_pack_start(GTK_BOX(GTK_DIALOG(dialog)->action_area), cancel_bt,
			   TRUE, TRUE, 0);

	gtk_widget_show_all(dialog);
    }
    else
    {
	gdk_window_raise(dialog->window);
    }
}


void tfmx_cfg_load(void)
{
	ConfigFile *cf ;
	if ( (cf = xmms_cfg_open_default_file()) == 0 )
		return ;
	xmms_cfg_read_boolean(cf, "tfmx", "loop_subsong", 
			      &plugin_cfg.loop_subsong);
	xmms_cfg_read_boolean(cf, "tfmx", "oversample", &plugin_cfg.over);
	xmms_cfg_read_boolean(cf, "tfmx", "stereo_blend", &plugin_cfg.blend);
	xmms_cfg_read_int(cf, "tfmx", "filter", &plugin_cfg.filt);
	xmms_cfg_free(cf);
	if ( plugin_cfg.filt > 3 )
		plugin_cfg.filt = 3 ;		
	if ( plugin_cfg.filt < 0 )
		plugin_cfg.filt = 0 ;		
}

void tfmx_cfg_save(void)
{
	ConfigFile *cf ;
	if ( (cf = xmms_cfg_open_default_file()) == 0 )
		return ;
	xmms_cfg_write_boolean(cf, "tfmx", "loop_subsong", 
			       plugin_cfg.loop_subsong);
	xmms_cfg_write_boolean(cf, "tfmx", "oversample", plugin_cfg.over);
	xmms_cfg_write_boolean(cf, "tfmx", "stereo_blend", plugin_cfg.blend);
	xmms_cfg_write_int(cf, "tfmx", "filter", plugin_cfg.filt);
	xmms_cfg_write_default_file(cf);
	xmms_cfg_free(cf);
}

