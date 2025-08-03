import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk
from fabric.widgets import Window, Label

window = Window(
    title="ПОЛНЫЙ УСПЕХ!",
    window_position=Gtk.WindowPosition.CENTER,
    default_width=600,
    default_height=200,
)
label = Label(
    label="Fabric и все его GTK-зависимости работают в NixOS!",
    font_size="large",
)
window.add(label)
window.connect("destroy", Gtk.main_quit)
window.show_all()
Gtk.main()
