Map<String, dynamic> extractorsManifest({
  int version = 1,
  List<Map<String, dynamic>>? extractors,
}) {
  return {
    'version': version,
    'extractors':
        extractors ??
        <Map<String, dynamic>>[
          {
            'domain': ['pinterest.com', 'pin.it'],
            'strategy': 'og_image',
            'needs_login': false,
          },
          {
            'domain': ['example.org'],
            'strategy': 'og_image',
            'needs_login': true,
          },
        ],
  };
}

Map<String, dynamic> presetsManifest() {
  return {
    'version': 1,
    'presets': [
      {
        'id': 'bold-outline',
        'name': 'Bold Outline',
        'stroke': {'color': '#111111', 'width': 4},
        'shadow': {'color': '#00000033', 'blur': 8},
        'background': {'color': '#FFFFFF'},
      },
    ],
  };
}

Map<String, dynamic> fontsManifest() {
  return {
    'version': 1,
    'fonts': [
      {
        'id': 'inter',
        'family': 'Inter',
        'file': 'Inter-Regular.ttf',
        'license_note': 'OFL-1.1',
      },
      {
        'id': 'montserrat',
        'family': 'Montserrat',
        'file': 'Montserrat-Bold.ttf',
      },
    ],
  };
}

Map<String, dynamic> themesManifest() {
  return {
    'version': 1,
    'themes': [
      {
        'id': 'default',
        'name': 'Sticker Studio',
        'tokens': {
          'colors': {
            'light': {'accent': '#7463b5'},
            'dark': {'accent': '#aa98ed'},
          },
          'spacing': {'s1': 4, 's2': 8},
          'radius': {'card': 20},
        },
      },
    ],
  };
}
