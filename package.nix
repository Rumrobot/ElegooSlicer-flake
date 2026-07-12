{
  lib,
  makeFontsConf,
  nanum,
  pkgs,
  source,
  withNvidiaGLWorkaround ? false,
}:
let
  src = pkgs.fetchurl {
    inherit (source) url;
    hash = source.sha256;
  };
  pname = "elegoo-slicer";
  version = source.version;

  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };

  # Workaround for crash due to missing font
  # https://github.com/OrcaSlicer/OrcaSlicer/issues/11641
  fontsConf = makeFontsConf {
    fontDirectories = [ nanum ];
    impureFontDirectories = [ ];
    includes = [ ];
  };
in
pkgs.appimageTools.wrapType2 rec {
  inherit pname version src;

  extraPkgs =
    pkgs:
    with pkgs;
    map lib.getLib [
      zstd
      libmspack
      libsoup_3
      webkitgtk_4_1

      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-good
    ];

  profile = ''
    export LD_LIBRARY_PATH=/usr/lib64:/usr/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
    export FONTCONFIG_FILE=${fontsConf}
    export WEBKIT_DISABLE_COMPOSITING_MODE=1
    ${lib.optionalString withNvidiaGLWorkaround ''
      export __GLX_VENDOR_LIBRARY_NAME=mesa
      export __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json
      export MESA_LOADER_DRIVER_OVERRIDE=zink
      export GALLIUM_DRIVER=zink
      export WEBKIT_DISABLE_DMABUF_RENDERER=1
    ''}
  '';

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/ElegooSlicer.desktop $out/share/applications/elegoo-slicer.desktop
    install -Dm444 ${appimageContents}/usr/share/icons/hicolor/192x192/apps/ElegooSlicer.png \
      $out/share/icons/hicolor/192x192/apps/ElegooSlicer.png
    substituteInPlace $out/share/applications/elegoo-slicer.desktop \
      --replace-fail 'Exec=AppRun %F' 'Exec=elegoo-slicer %F'
  '';

  meta = {
    description = "G-code generator for ELEGOO 3D printers (OrcaSlicer fork)";
    homepage = "https://github.com/ELEGOO-3D/ElegooSlicer";
    license = lib.licenses.agpl3Only;
    mainProgram = "elegoo-slicer";
    platforms = [ "x86_64-linux" ];
  };
}
