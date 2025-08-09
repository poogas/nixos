# /etc/nixos/system/modules/fabric.nix

{ lib, pkgs, inputs, python311Packages, gtk3, gtk-layer-shell, cairo, gobject-introspection, libdbusmenu-gtk3, gdk-pixbuf, cinnamon, gnome, pkg-config, wrapGAppsHook3 }:

python311Packages.buildPythonPackage {
  pname = "python-fabric";
  version = "unstable";
  pyproject = true;

  src = inputs.fabric;

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
    gobject-introspection
    cairo
  ];

  propagatedBuildInputs = [
    gtk3
    gtk-layer-shell
    libdbusmenu-gtk3
    cinnamon.cinnamon-desktop
    gnome.gnome-bluetooth
  ];

  propagatedBuildInputs = with python311Packages; [
    setuptools
    click
    pycairo
    pygobject3
    loguru
    psutil
  ];

  doCheck = false;

  meta = {
    description = "Fabric GTK framework from your flake inputs";
    homepage = "https://github.com/Fabric-Development/fabric";
  };
}
