final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (python-final: python-prev: {
      python-fabric = final.callPackage ./modules/fabric.nix {
        inherit (final) lib pkgs inputs python311Packages gtk3 gtk-layer-shell cairo gobject-introspection libdbusmenu-gtk3 gdk-pixbuf cinnamon gnome pkg-config wrapGAppsHook3;
      };
    })
  ];
}
