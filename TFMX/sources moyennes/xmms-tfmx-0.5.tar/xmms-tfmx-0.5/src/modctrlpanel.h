#ifndef MODCTRLPANEL_H
#define MODCTRLPANEL_H

#include <gtk/gtkwindow.h>

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */


#define MODCTRLPANEL(obj)          GTK_CHECK_CAST (obj, modctrlpanel_get_type (), ModCtrlPanel)
#define MODCTRLPANEL_CLASS(klass)  GTK_CHECK_CLASS_CAST (klass, modctrlpanel_get_type (), ModCtrlPanelClass)
#define IS_MODCTRLPANEL(obj)       GTK_CHECK_TYPE (obj, modctrlpanel_get_type ())

typedef struct _ModCtrlPanel ModCtrlPanel;
typedef struct _ModCtrlPanelClass ModCtrlPanelClass;


struct _ModCtrlPanel {
    GtkWindow window;

    GtkWidget *main_vbox;
    GtkWidget *text;
    GtkWidget *label_position;
    GtkWidget *label_song;
    GtkWidget *next_song_button;
    GtkWidget *prev_song_button;
    GtkWidget *next_position_button;
    GtkWidget *prev_position_button;

    gint current_position;
    gint current_song;

    gint max_position; /* npos - 1 */
    gint max_song;
};

struct _ModCtrlPanelClass
{
    GtkWindowClass parent_class;
    
    void (* position_changed) (ModCtrlPanel *mcp, gint position);
    void (* song_changed) (ModCtrlPanel *mcp, gint song);
};

guint      modctrlpanel_get_type (void);
GtkWidget *modctrlpanel_new (void);

void modctrlpanel_set_position (ModCtrlPanel *mcp, gint position);
void modctrlpanel_set_song (ModCtrlPanel *mcp, gint song);

void 
modctrlpanel_set_max_position (ModCtrlPanel *mcp, gint maxposition);
void 
modctrlpanel_set_max_song (ModCtrlPanel *mcp, gint maxsong);
void 
modctrlpanel_position_buttons_set_sensitive (ModCtrlPanel *mcp, gboolean flag);

void 
modctrlpanel_set_info_text (ModCtrlPanel *mcp, const gchar *text);


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif
