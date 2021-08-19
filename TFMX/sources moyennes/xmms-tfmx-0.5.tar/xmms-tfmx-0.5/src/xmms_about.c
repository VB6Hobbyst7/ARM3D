#include <gtk/gtk.h>

static GtkWidget *dialog = NULL;

static void about_close_cb(GtkWidget *w, gpointer data)
{
	gtk_widget_destroy(dialog);
}

static int 
init_dialog (GtkWidget *dialog)
{
    GtkWidget *dialog_vbox1;
    GtkWidget *hbox1, *label, *button;

    dialog_vbox1 = GTK_DIALOG(dialog)->vbox;
    gtk_container_border_width(GTK_CONTAINER(dialog_vbox1), 5);
    hbox1 = gtk_hbox_new(FALSE, 0);
    gtk_box_pack_start(GTK_BOX(dialog_vbox1), hbox1, TRUE, TRUE, 0);
    gtk_container_border_width(GTK_CONTAINER(hbox1), 5);

    label = gtk_label_new(
	"TFMX plugin adapted to xmms by David Le Corfec\n"
"<dlecorfec@users.sourceforge.net>\n"
"Original code (tfmxplay) by Jonathan H. Pickard, ported to Winamp by Per Linden\n\n"
"TFMX was created by Chris Huelsbeck.\n"
);
    gtk_box_pack_start(GTK_BOX(dialog_vbox1), label,
		       TRUE, TRUE, 5);


    button = gtk_button_new_with_label(" Close ");
    gtk_signal_connect(GTK_OBJECT(button), "clicked",
		       GTK_SIGNAL_FUNC(about_close_cb), NULL);
    gtk_box_pack_start(GTK_BOX(GTK_DIALOG(dialog)->action_area), button,
		       FALSE, FALSE, 0);

    return 1;
}

void 
ip_about(void)
{
    if (!dialog)
    {
	dialog = gtk_dialog_new();
	gtk_window_set_title(GTK_WINDOW(dialog), "About TFMX plugin");
	gtk_window_set_policy(GTK_WINDOW(dialog), FALSE, FALSE, FALSE);
	gtk_window_set_position(GTK_WINDOW(dialog), GTK_WIN_POS_MOUSE);
	gtk_signal_connect(GTK_OBJECT(dialog), "destroy",
			   GTK_SIGNAL_FUNC(gtk_widget_destroyed), &dialog);
	gtk_container_border_width(GTK_CONTAINER(dialog), 10);

	init_dialog(dialog);
	
	gtk_widget_show_all(dialog);
    }
    else
    {
	gdk_window_raise(dialog->window);
    }
}

