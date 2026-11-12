#!/usr/bin/env python3
"""Describe active Mango bindings for the shell's keyboard shortcut sheet."""
import json
import os
from pathlib import Path
import shlex
import sys
import tomllib

CATEGORIES = ['Shell', 'Workspaces', 'Windows', 'Applications', 'Media', 'Hardware', 'Other']
MODIFIERS = {'SUPER': 'Super', 'LOGO': 'Super', 'MOD4': 'Super', 'CTRL': 'Ctrl', 'CONTROL': 'Ctrl', 'ALT': 'Alt', 'MOD1': 'Alt', 'SHIFT': 'Shift', 'NONE': ''}
KEYS = {'xf86monbrightnessup':'Brightness ↑', 'xf86monbrightnessdown':'Brightness ↓', 'xf86audioraisevolume':'Volume ↑', 'xf86audiolowervolume':'Volume ↓', 'xf86audiomute':'Speaker mute', 'xf86audiomicmute':'Mic mute', 'xf86audioplay':'Play / pause', 'xf86audionext':'Next track', 'xf86audioprev':'Previous track', 'xf86audiostop':'Stop media', 'xf86kbdbrightnessup':'Keyboard light ↑', 'xf86kbdbrightnessdown':'Keyboard light ↓', 'xf86kbdlightonoff':'Keyboard light', 'space':'Space', 'slash':'/', 'backslash':'\\', 'comma':',', 'period':'.', 'equal':'=', 'minus':'−', 'return':'Enter', 'escape':'Esc', 'super_l':'Left Super', 'super_r':'Right Super', 'page_up':'Page Up', 'page_down':'Page Down', 'backspace':'Backspace', 'btn_left':'Left click', 'btn_right':'Right click', 'btn_middle':'Middle click'}
HARDWARE = {
    'XF86MonBrightnessUp': 'Increase screen brightness', 'XF86MonBrightnessDown': 'Decrease screen brightness',
    'XF86AudioRaiseVolume': 'Increase volume', 'XF86AudioLowerVolume': 'Decrease volume',
    'XF86AudioMute': 'Mute / unmute speakers', 'XF86AudioMicMute': 'Mute / unmute microphone',
    'XF86KbdBrightnessUp': 'Increase keyboard brightness', 'XF86KbdBrightnessDown': 'Decrease keyboard brightness',
    'XF86KbdLightOnOff': 'Toggle keyboard backlight',
}
ACTIONS = {
    'killclient':'Close window', 'togglefloating':'Toggle floating window', 'togglefullscreen':'Toggle fullscreen',
    'togglemaximizescreen':'Toggle maximized window', 'togglefakefullscreen':'Toggle fake fullscreen', 'toggleglobal':'Pin / unpin window',
    'toggle_special_tag':'Toggle special overlay', 'tag_special_tag':'Move window to / from special overlay',
    'minimized':'Minimize window', 'restore_minimized':'Restore minimized window', 'toggle_scratchpad':'Toggle scratchpad',
    'groupleave':'Remove window from group', 'switch_layout':'Cycle window layout', 'toggleoverview':'Toggle overview',
    'enteroverview':'Open overview', 'leaveoverview':'Close overview', 'reload_config':'Reload compositor settings',
    'switch_proportion_preset':'Cycle column width', 'dwindle_toggle_split_direction':'Change split direction',
    'centerwin':'Center window', 'toggleoverlay':'Toggle window overlay', 'togglegaps':'Toggle window gaps',
}


def describe(action, args, key):
    if key in HARDWARE and action == 'spawn' and any(token in ','.join(args) for token in ('brightnessctl', 'wpctl', 'call audio ', 'trigger brightness', 'keyboard-light')):
        return 'Hardware', HARDWARE[key]
    if action == 'spawn':
        command = ','.join(args)
        try:
            words = shlex.split(command)
        except ValueError:
            return 'Other', command
        if 'call' in words and 'qs' in words:
            call = words[words.index('call') + 1:]
            if len(call) >= 2:
                target, method, *arguments = call
                if target == 'drawers':
                    return 'Shell', 'Toggle ' + ' '.join(arguments)
                if target == 'shortcuts':
                    names = {'showall':'Toggle all drawers', 'brightnessUp':'Increase screen brightness', 'brightnessDown':'Decrease screen brightness'}
                    return 'Shell', names.get(' '.join(arguments), ' '.join(arguments))
                labels = {'windowRules':'Window rule manager', 'keybindings':'Keyboard shortcut sheet', 'lock':'Lock screen', 'nexus':'Open settings', 'gameMode':'Toggle game mode', 'idleInhibitor':'Toggle idle inhibition', 'notifs':'Clear notifications', 'picker':'Take screenshot', 'areazoom':'Area zoom', 'recorder':'Toggle recording', 'mpris':'Media', 'audio':'Audio'}
                label = labels.get(target, target)
                extra = {'openFreeze':' (frozen selection)', 'openClip':' to clipboard', 'openFreezeClip':' to clipboard (frozen)', 'next':'next track', 'previous':'previous track', 'playPause':'play / pause', 'stop':'stop', 'pause':'pause'}
                if target in ('mpris', 'audio'):
                    return 'Media', label + ': ' + extra.get(method, method)
                if target == 'recorder':
                    return 'Media', label + (' with sound' if arguments == ['sound'] else ' in selected region' if arguments == ['region'] else '')
                return 'Shell', label + extra.get(method, '')
        helper = next((i for i, word in enumerate(words) if Path(word).name == 'mango-actions.py'), None)
        if helper is not None:
            command = words[helper + 1:]
            if not command:
                return 'Other', 'Shell action'
            operation, *values = command
            if operation == 'workspace' and len(values) == 3:
                movement, kind, number = values
                verb = 'Move window to' if movement == 'move' else 'Switch to'
                destination = {'slot':f'workspace {number} in current group', 'group':f'workspace group {number}', 'relative':f'workspace {int(number):+d} from current'}
                return 'Workspaces', verb + ' ' + destination.get(kind, kind)
            if operation == 'app':
                return 'Applications', 'Open ' + ' '.join(values)
            if operation == 'scratchpad':
                return 'Applications', 'Toggle ' + ' '.join(values) + ' scratchpad'
            labels = {'special-out':'Return window from special overlay', 'group-toggle':'Toggle window group', 'normalize':'Resize and center window', 'pip':'Picture-in-picture window', 'screenshot':'Screenshot active screen', 'clipboard':'Clipboard history', 'clipboard-delete':'Delete clipboard entry', 'clipboard-latest':'Paste latest clipboard entry', 'emoji':'Emoji picker', 'colour':'Pick a colour', 'restart':'Restart shell', 'kill':'Stop shell', 'keyboard-light':'Toggle keyboard backlight'}
            return ('Windows' if operation in ('special-out','group-toggle','normalize','pip') else 'Shell'), labels.get(operation, operation)
        if words:
            if words[0] == 'systemctl': return 'Shell', ' '.join(words[1:]).capitalize()
            if words[0] == 'wpctl': return 'Media', 'Adjust audio'
            return 'Applications', 'Launch ' + Path(words[0]).name + (' ' + ' '.join(words[1:]) if len(words) > 1 else '')
    if action in ('view', 'viewcrossmon', 'tag', 'tagsilent', 'tagcrossmon'):
        return 'Workspaces', ('Move window to workspace ' if action.startswith('tag') else 'Switch to workspace ') + (args[0] if args else '')
    if action.startswith(('viewto','viewprev','viewnext')):
        return 'Workspaces', action.replace('_', ' ').capitalize()
    if action in ('focusdir', 'move_client', 'scroller_stack', 'focusmon', 'focusstack', 'groupfocus'):
        verb = {'focusdir':'Focus window', 'move_client':'Move window', 'scroller_stack':'Stack column', 'focusmon':'Focus monitor', 'focusstack':'Cycle windows', 'groupfocus':'Cycle group windows'}[action]
        return 'Windows', verb + ' ' + ' '.join(args)
    if action in ('movewin', 'resizewin', 'moveresize', 'incgaps', 'setlayout', 'set_proportion'):
        verb = {'movewin':'Move window', 'resizewin':'Resize window', 'moveresize':'Drag window' if args == ['curmove'] else 'Resize window with mouse', 'incgaps':'Adjust window gaps', 'setlayout':'Use layout', 'set_proportion':'Set column width'}[action]
        return 'Windows', verb + (' ' + ' '.join(args) if action != 'moveresize' else '')
    if action in ACTIONS:
        return ('Shell' if action == 'reload_config' else 'Workspaces' if 'special' in action else 'Windows'), ACTIONS[action]
    return 'Other', (action.replace('_', ' ') + ' ' + ' '.join(args)).strip().capitalize()


def read_bindings(path, bindings=None, mode='default', stack=None):
    bindings = {} if bindings is None else bindings
    stack = set() if stack is None else stack
    path = path.expanduser().resolve()
    if path in stack:
        raise ValueError(f'Cyclic Mango source: {path}')
    if len(stack) > 50:
        raise ValueError('Too many nested Mango sources')
    stack.add(path)
    if path.suffix == '.toml':
        data = tomllib.loads(path.read_text())
        entries = list(data.get('global', {}).items())
        for family in ('bind', 'bindr', 'binde', 'mousebind', 'axisbind'):
            for keymode, values in data.get(family, {}).items():
                entries.append(('key_mode', keymode))
                for chord, action in values.items():
                    parts = chord.split('+')
                    entries.append((family, ','.join(['+'.join(parts[:-1]) or 'NONE', parts[-1], action])))
    else:
        entries = []
        for line in path.read_text().splitlines():
            line = line.split('#', 1)[0].strip()
            if '=' in line:
                entries.append(tuple(part.strip() for part in line.split('=', 1)))
    for kind, value in entries:
        if kind in ('source', 'source_optional'):
            for name in value if isinstance(value, list) else [value]:
                child = Path(os.path.expandvars(str(name).strip('"\''))).expanduser()
                if not child.is_absolute(): child = path.parent / child
                if kind == 'source_optional' and not child.exists(): continue
                _, mode = read_bindings(child, bindings, mode, stack)
        elif kind == 'key_mode':
            mode = value
        elif kind.startswith(('bind', 'mousebind', 'axisbind')):
            fields = [part.strip() for part in value.split(',')]
            if len(fields) < 3: continue
            modifiers, key, action, *args = fields
            while args and not args[-1]: args.pop()
            mods = sorted(set(MODIFIERS.get(mod.upper(), mod.title()) for mod in modifiers.split('+')) - {''}, key=lambda x: ['Super','Ctrl','Alt','Shift'].index(x) if x in ['Super','Ctrl','Alt','Shift'] else 5)
            family = 'mouse' if kind.startswith('mousebind') else 'scroll' if kind.startswith('axisbind') else 'release' if 'r' in kind[4:] else 'press'
            chord = ' + '.join([*mods, KEYS.get(key.lower(), key if key.startswith('XF86') else key.capitalize())])
            try:
                category, label = describe(action, args, key)
            except (ValueError, KeyError, TypeError):
                category, label = 'Other', ' '.join([action, *args])
            if key.lower() in ('super_l', 'super_r') and mods == ['Super']:
                chord = KEYS[key.lower()]
            if family == 'release': chord += ' · release'
            elif family == 'scroll': chord = ' + '.join([*mods, 'Scroll ' + key.lower()])
            bindings[(mode, family, tuple(mods), key.lower())] = {'keys':chord, 'description':label, 'category':category, 'mode':mode}
    stack.remove(path)
    return bindings, mode


def main():
    folder = Path(os.environ.get('XDG_CONFIG_HOME', Path.home() / '.config')) / 'mango'
    requested = os.environ.get('CAELESTIA_MANGO_CONFIG')
    path = Path(requested).expanduser() if requested else next((p for p in [folder/'config.conf', folder/'config.toml', Path('/etc/mango/config.conf')] if p.exists()), None)
    if path is None:
        raise ValueError('No Mango configuration was found')
    bindings, _ = read_bindings(path)
    rows = sorted(bindings.values(), key=lambda row: (CATEGORIES.index(row['category']), row['mode'], row['description'], row['keys']))
    print(json.dumps({'bindings':rows}))


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, TypeError) as error:
        print(json.dumps({'bindings':[], 'error':str(error)}))
        sys.exit(1)
