# Theming

```
theme.json -> Theme.qml <- user (prefs.json)
```

`theme.json` holds 16 palette colors, `base00`..`base0F`. Edit them by hand, or let a theme tool such as Stylix fill them.

`Theme.qml` defines the classes (`textBody`, `iconBody`, `fillCard`...). Each class uses one palette slot.

## Kinds
A class belongs to one kind of element:
- `text*` for text (`Label`)
- `icon*` for icons (`Glyph`)
- `fill*` for backgrounds and filled parts
- `line*` for dividers and borders
- `titlebar*` for Wayfire title bars

Four state colors fit any kind, so they are one input each: `selected`, `danger`, `warning`, `success`.
They color text, icons and fills the same way.

Knobs (slider, toggle) use `textBody` and `textPrimary`. They have no token of their own.

Text and icons never share a class. `check.sh` fails if a token is used on the wrong kind.

The user picks a slot per class in Settings > Appearance. Picks are saved in `prefs.json`, like `{"selected": "base0E"}`.

## Fallbacks
bad pick -> the class default slot -> built-in color.

## Safety
A color change reverts after 10 s unless you press Keep.

## Add a class
1. Add an entry to `classes` in `Theme.qml` (id, group, label, hint, default slot).
2. Add its `readonly property color` line.
3. Use it on the right kind of element. `./check.sh` tells you if not.

The Appearance page lists it by itself, inside its group. Groups open and close with a click.

## Fonts
`Theme.font` is the font in `theme.json` unless the user picks one. Text sizes scale with the size pick.

## Wallpaper
`modules/appearance/Wallpaper.qml` draws one background window per screen.
All screens share one decoded copy of the picture.

## Window title bars (the hack)

```
pick color -> panel -> theme.lua -> Wayfire set-config-options
                                  -> nudge each window by 1 px and back
```

Wayfire reads the colors live. But an open window only repaints its title bar when its size changes.

So `compositor/theme.lua` sets the colors and font, then resizes each normal window by 1 px and back. It skips fullscreen, minimized and tiled windows.

Known limit: the title text color changes only when that window's title changes, and on new windows.

The IPC method is `set-config-options`, plural.
`services/WayfireTheme.qml` runs the script at startup and on every pick.
