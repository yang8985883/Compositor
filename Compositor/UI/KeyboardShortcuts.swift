import AppKit
import SwiftUI

struct ShortcutChord: Codable, Equatable, Hashable {
    var key: String
    var modifiers: Int
    init(_ key: String, _ modifiers: Int = 0) { self.key = key; self.modifiers = modifiers }
    // Stable stored bits: Command, Option, Control, Shift.
    init(_ event: NSEvent) {
        let flags = event.modifierFlags
        modifiers = (flags.contains(.command) ? 1 : 0) | (flags.contains(.option) ? 2 : 0)
            | (flags.contains(.control) ? 4 : 0) | (flags.contains(.shift) ? 8 : 0)
        switch event.keyCode {
        case 51, 117: key = "\u{7f}"
        case 36, 76: key = "\r"
        case 53: key = "\u{1b}"
        case 48: key = "\t"
        case 49: key = " "
        case 123: key = "\u{f702}"
        case 124: key = "\u{f703}"
        case 125: key = "\u{f701}"
        case 126: key = "\u{f700}"
        default:
            let typed = event.charactersIgnoringModifiers?.lowercased() ?? ""
            key = ["{": "[", "}": "]", "+": "=", "_": "-" ][typed] ?? typed
        }
    }
    var eventModifiers: EventModifiers {
        var flags: EventModifiers = []
        if modifiers & 1 != 0 { flags.insert(.command) }
        if modifiers & 2 != 0 { flags.insert(.option) }
        if modifiers & 4 != 0 { flags.insert(.control) }
        if modifiers & 8 != 0 { flags.insert(.shift) }
        return flags
    }
    var cocoaModifiers: NSEvent.ModifierFlags {
        var flags: NSEvent.ModifierFlags = []
        if modifiers & 1 != 0 { flags.insert(.command) }
        if modifiers & 2 != 0 { flags.insert(.option) }
        if modifiers & 4 != 0 { flags.insert(.control) }
        if modifiers & 8 != 0 { flags.insert(.shift) }
        return flags
    }
    var label: String {
        let special = ["\u{7f}": "Delete", "\r": "Return", "\u{1b}": "Esc", "\t": "Tab", " ": "Space",
                       "\u{f702}": "←", "\u{f703}": "→", "\u{f701}": "↓", "\u{f700}": "↑"]
        return (modifiers & 4 != 0 ? "⌃" : "") + (modifiers & 2 != 0 ? "⌥" : "")
            + (modifiers & 8 != 0 ? "⇧" : "") + (modifiers & 1 != 0 ? "⌘" : "")
            + (special[key] ?? key.uppercased())
    }
    func event(like event: NSEvent) -> NSEvent? {
        let codes: [String: UInt16] = ["\u{7f}": 51, "\r": 36, "\u{1b}": 53, "\t": 48, " ": 49,
                                       "\u{f702}": 123, "\u{f703}": 124, "\u{f701}": 125, "\u{f700}": 126,
                                       "=": 24, "-": 27]
        let shifted = modifiers & 8 != 0 ? (["[": "{", "]": "}", "=": "+", "-": "_"][key] ?? key) : key
        return NSEvent.keyEvent(with: event.type, location: event.locationInWindow, modifierFlags: cocoaModifiers,
            timestamp: event.timestamp, windowNumber: event.windowNumber, context: nil,
            characters: shifted, charactersIgnoringModifiers: shifted, isARepeat: event.isARepeat,
            keyCode: codes[key] ?? 0xffff)
    }
}

struct ShortcutDefinition: Identifiable {
    let title: String
    let group: String
    let original: ShortcutChord
    var id: String { "\(group):\(title)" }
    var isMenu: Bool { group == "Menus" }

    static let all: [ShortcutDefinition] = {
        func entry(_ title: String, _ key: String, _ modifiers: Int = 0, menu: Bool = false) -> ShortcutDefinition {
            .init(title: title, group: menu ? "Menus" : "Canvas & Layers", original: ShortcutChord(key, modifiers))
        }
        var result: [ShortcutDefinition] = [
            entry(loc("Undo"), "z", 1, menu: true), entry(loc("Redo"), "z", 9, menu: true),
            entry(loc("New Canvas"), "n", 1, menu: true), entry(loc("Open Project"), "o", 1, menu: true),
            entry(loc("Save"), "s", 1, menu: true), entry(loc("Save As"), "s", 9, menu: true),
            entry(loc("Export PNG"), "e", 9, menu: true), entry(loc("Export JPEG"), "s", 11, menu: true),
            entry(loc("Close Project"), "w", 1, menu: true), entry(loc("Fit Canvas"), "0", 1, menu: true), entry(loc("Command Palette"), "f", 1, menu: true),
            entry(loc("Actual Pixels"), "1", 1, menu: true), entry(loc("Zoom In"), "=", 1, menu: true),
            entry(loc("Zoom Out"), "-", 1, menu: true), entry(loc("Show Transform Controls"), "h", 1, menu: true),
            entry(loc("Hide Compositor"), "h", 3, menu: true), entry(loc("Cut"), "x", 1, menu: true),
            entry(loc("Copy"), "c", 1, menu: true), entry(loc("Copy Merged"), "c", 9, menu: true),
            entry(loc("Paste"), "v", 1, menu: true), entry(loc("Fill with Foreground"), "\u{7f}", 2, menu: true),
            entry(loc("Fill with Background"), "\u{7f}", 1, menu: true), entry(loc("Content-Aware Fill"), "\u{7f}", 8, menu: true),
            entry(loc("Select All"), "a", 1, menu: true), entry(loc("Deselect"), "d", 1, menu: true),
            entry(loc("Inverse Selection"), "i", 9, menu: true), entry(loc("Select Subject"), "a", 3, menu: true),
            entry(loc("Curves"), "m", 1, menu: true), entry(loc("Levels"), "l", 1, menu: true),
            entry(loc("Hue/Saturation"), "u", 1, menu: true), entry(loc("Invert Pixels / Mask"), "i", 1, menu: true),
            entry(loc("Canvas Size"), "c", 3, menu: true), entry(loc("Image Size"), "i", 3, menu: true),
            entry(loc("Transform Layer / Selection"), "t", 1, menu: true), entry(loc("Duplicate / Layer via Copy"), "j", 1, menu: true),
            entry(loc("Toggle Clipping Mask"), "g", 3, menu: true), entry(loc("Group Layers"), "g", 1, menu: true),
            entry(loc("Ungroup Layers"), "g", 9, menu: true),
            entry(loc("New Blank Layer"), "n", 9, menu: true), entry(loc("Move Layer Up"), "]", 1, menu: true),
            entry(loc("Move Layer Down"), "[", 1, menu: true), entry(loc("Merge Layers"), "e", 1, menu: true),
            entry(loc("Show Grid"), "'", 1, menu: true), entry(loc("Show Guides"), ";", 1, menu: true),
            entry(loc("Show Rulers"), "r", 1, menu: true), entry(loc("Snap"), ";", 9, menu: true),
            entry(loc("Lock Guides"), ";", 3, menu: true)
        ]
        for (title, key) in [(loc("Canvas Only: full screen on black, without panels"), "f"), (loc("Select tool"), "a"), (loc("Move / Transform tool"), "v"), (loc("Hand tool"), "h"),
            (loc("Zoom tool"), "z"), (loc("Brush tool"), "b"), (loc("Eraser"), "e"), (loc("Spot Healing"), "j"),
            (loc("Clone Stamp"), "s"), (loc("Type tool"), "t"), (loc("Gradient tool"), "g"), (loc("Shape tool"), "u"),
            (loc("Eyedropper tool"), "i"), (loc("Marquee / cycle shape"), "m"), (loc("Magic"), "w"),
            (loc("Lasso / cycle mode"), "l"), (loc("Blur / Smudge / Liquify"), "r"), (loc("Crop tool"), "c"),
            (loc("Swap foreground/background"), "x"), (loc("Reset colors"), "d"), (loc("Cycle tool mode"), "\t"),
            (loc("Temporary Hand tool (hold)"), " "), (loc("Delete selection / layer / effect / lasso point"), "\u{7f}"),
            (loc("Apply current canvas operation"), "\r"), (loc("Cancel current canvas operation"), "\u{1b}"),
            (loc("Decrease brush size"), "["), (loc("Increase brush size"), "]")] {
            result.append(entry(title, key))
        }
        result += [entry(loc("Decrease brush hardness"), "[", 8), entry(loc("Increase brush hardness"), "]", 8),
                   entry(loc("Previous blend mode"), "-", 8), entry(loc("Next blend mode"), "=", 8),
                   entry(loc("Cycle shape kind"), "u", 8)]
        for digit in 0...9 { result.append(entry(String(format: loc("Opacity digit %d (type two for exact %%)"), digit), String(digit))) }
        for (direction, key) in [("Left", "\u{f702}"), ("Right", "\u{f703}"), ("Up", "\u{f700}"), ("Down", "\u{f701}")] {
            let way = loc(direction)
            result += [entry(String(format: loc("Nudge %@ 1 px"), way), key), entry(String(format: loc("Nudge %@ 10 px"), way), key, 8),
                       entry(String(format: loc("Move selected pixels %@ 1 px"), way), key, 1), entry(String(format: loc("Move selected pixels %@ 10 px"), way), key, 9)]
        }
        result.append(.init(title: loc("Finish editing text"), group: "Text Editing", original: ShortcutChord("\r", 1)))
        for (title, key) in [(loc("Decrease tracking"), "\u{f702}"), (loc("Increase tracking"), "\u{f703}"),
                             (loc("Decrease leading"), "\u{f700}"), (loc("Increase leading"), "\u{f701}")] {
            result.append(.init(title: title, group: "Text Editing", original: ShortcutChord(key, 2)))
            result.append(.init(title: String(format: loc("%@ by 10"), title), group: "Text Editing", original: ShortcutChord(key, 10)))
        }
        result.append(entry(loc("Toggle Levels preview"), "p", 2))
        return result
    }()
}

@MainActor @Observable
final class ShortcutSettings {
    static let shared = ShortcutSettings()
    private(set) var overrides: [String: ShortcutChord] = [:]
    @ObservationIgnored private let panel = FloatingPanelController(name: "keyboardShortcuts")
    private static let storageKey = "keyboardShortcuts.v1"
    private init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let saved = try? JSONDecoder().decode([String: ShortcutChord].self, from: data),
           Self.problem(in: saved) == nil { overrides = saved }
    }
    func chord(_ definition: ShortcutDefinition) -> ShortcutChord { overrides[definition.id] ?? definition.original }
    func menu(_ key: KeyEquivalent, modifiers: EventModifiers) -> ShortcutChord {
        let bits = (modifiers.contains(.command) ? 1 : 0) | (modifiers.contains(.option) ? 2 : 0)
            | (modifiers.contains(.control) ? 4 : 0) | (modifiers.contains(.shift) ? 8 : 0)
        let original = ShortcutChord(String(key.character), bits)
        guard let definition = ShortcutDefinition.all.first(where: { $0.isMenu && $0.original == original }) else { return original }
        return chord(definition)
    }
    func native(_ key: KeyEquivalent, modifiers: EventModifiers = []) -> ShortcutChord {
        let bits = (modifiers.contains(.command) ? 1 : 0) | (modifiers.contains(.option) ? 2 : 0)
            | (modifiers.contains(.control) ? 4 : 0) | (modifiers.contains(.shift) ? 8 : 0)
        let original = ShortcutChord(String(key.character), bits)
        guard let definition = ShortcutDefinition.all.first(where: { !$0.isMenu && $0.original == original }) else { return original }
        return chord(definition)
    }
    func show() {
        panel.show(title: loc("Keyboard Shortcuts"), content: KeyboardShortcutsSheet(settings: self))
    }
    func close() { panel.close() }
    func save(_ values: [String: ShortcutChord]) {
        guard Self.problem(in: values) == nil, let data = try? JSONEncoder().encode(values) else { return }
        overrides = values
        UserDefaults.standard.set(data, forKey: Self.storageKey)
        close()
    }
    static func problem(in values: [String: ShortcutChord]) -> String? {
        var assigned: [ShortcutChord: String] = [:]
        for definition in ShortcutDefinition.all {
            let chord = values[definition.id] ?? definition.original
            guard chord.key.count == 1, (0...15).contains(chord.modifiers) else { return loc("Choose a single key with optional modifiers.") }
            if definition.group == "Text Editing", chord.modifiers & 7 == 0 {
                return loc("Text-editing shortcuts need Command, Option, or Control so they do not replace normal typing.")
            }
            if [ShortcutChord("q", 1), ShortcutChord(",", 1), ShortcutChord("m", 3)].contains(chord) {
                return String(format: loc("%@ is reserved by macOS."), chord.label)
            }
            if let other = assigned[chord] { return String(format: loc("%1$@ is assigned to both %2$@ and %3$@."), chord.label, other, definition.title) }
            assigned[chord] = definition.title
        }
        return nil
    }

    /// Translate only at the existing canvas/layer responder boundary. Native text
    /// fields and dialog controls retain their normal typing and navigation behavior.
    func canvasEvent(_ event: NSEvent) -> NSEvent? {
        guard !overrides.isEmpty else { return event }
        let input = ShortcutChord(event)
        if let definition = ShortcutDefinition.all.first(where: { $0.group == "Canvas & Layers" && chord($0) == input }) {
            return definition.original == input ? event : definition.original.event(like: event)
        }
        if ShortcutDefinition.all.contains(where: { $0.group != "Text Editing" && $0.original == input && chord($0) != input }) { return nil }
        // Letter tool shortcuts traditionally also accept Shift. Follow the base
        // assignment unless Shift has its own explicit command (e.g. cycle shape).
        if input.modifiers == 8 {
            let plain = ShortcutChord(input.key)
            if let definition = ShortcutDefinition.all.first(where: { !$0.isMenu && $0.original.modifiers == 0 && chord($0) == plain }) {
                return ShortcutChord(definition.original.key, 8).event(like: event)
            }
            if ShortcutDefinition.all.contains(where: { !$0.isMenu && $0.original == plain && chord($0) != plain }) { return nil }
        }
        return event
    }

    func textEvent(_ event: NSEvent) -> NSEvent? {
        guard !overrides.isEmpty else { return event }
        let definitions = ShortcutDefinition.all.filter { $0.group == "Text Editing" || $0.original == ShortcutChord("\u{1b}") }
        let input = ShortcutChord(event)
        if let definition = definitions.first(where: { chord($0) == input }) {
            return definition.original == input ? event : definition.original.event(like: event)
        }
        if definitions.contains(where: { $0.original == input && chord($0) != input }) { return nil }
        return event
    }
}

extension View {
    func configuredNativeShortcut(_ key: KeyEquivalent, modifiers: EventModifiers = []) -> some View {
        let chord = ShortcutSettings.shared.native(key, modifiers: modifiers)
        guard let first = chord.key.first else { return keyboardShortcut(key, modifiers: modifiers) }
        return keyboardShortcut(KeyEquivalent(first), modifiers: chord.eventModifiers)
    }
    func configuredKeyboardShortcut(_ key: KeyEquivalent, modifiers: EventModifiers = .command) -> some View {
        let chord = ShortcutSettings.shared.menu(key, modifiers: modifiers)
        guard let first = chord.key.first else { return keyboardShortcut(key, modifiers: modifiers) }
        return keyboardShortcut(KeyEquivalent(first), modifiers: chord.eventModifiers)
    }
}

private struct KeyboardShortcutsSheet: View {
    let settings: ShortcutSettings
    @State private var draft: [String: ShortcutChord]
    @State private var search = ""
    @State private var recording: String?
    init(settings: ShortcutSettings) { self.settings = settings; _draft = State(initialValue: settings.overrides) }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Click a shortcut, then press its new key combination. Changes apply when you save.")
                .foregroundStyle(.secondary)
            TextField("Search shortcuts", text: $search).textFieldStyle(.roundedBorder)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    ForEach(["Menus", "Canvas & Layers", "Text Editing"], id: \.self) { group in
                        Text(loc(group)).font(.headline).padding(.top, 8)
                        ForEach(ShortcutDefinition.all.filter { $0.group == group && (search.isEmpty || $0.title.localizedCaseInsensitiveContains(search)) }) { definition in
                            HStack {
                                Text(definition.title)
                                Spacer()
                                ShortcutRecorder(chord: draft[definition.id] ?? definition.original,
                                    recording: recording == definition.id,
                                    start: { recording = definition.id },
                                    finish: { chord in
                                        if let chord { draft[definition.id] = chord }
                                        recording = nil
                                    })
                                    .frame(width: 150, height: 26)
                            }
                        }
                    }
                    Divider().padding(.vertical, 8)
                    Text("Contextual keys & mouse gestures").font(.headline)
                    Text("Text fields keep standard macOS editing keys. Dialogs share the Apply/Cancel assignments above. Numeric fields use Up/Down, with Shift for larger steps. Standard macOS commands include ⌘Q to quit and ⌃⌘F for full screen. The shortcut editor itself always uses Return to save and Esc to cancel when not recording.")
                    Text("Option temporarily selects the eyedropper in painting tools. Shift constrains shapes/movement or adds to a selection; Option subtracts from selections or draws from center. Command-drag moves selected pixels; Command-Option-drag copies them. Option-drag duplicates layers/folders/effects; Option-click at a layer boundary toggles clipping. Command-click a thumbnail loads its selection. Control bypasses snapping. Right-drag adjusts brush size. Modifier-and-mouse gestures are fixed.")
                }.padding(.trailing, 8)
            }.frame(height: 465)
            // Only a conflict takes room here; an empty line left a wide gap above the buttons.
            if let problem = ShortcutSettings.problem(in: draft) {
                Text(problem)
                    .foregroundStyle(.orange).font(.callout).lineLimit(2)
                    .frame(height: 22, alignment: .topLeading)
            }
            Divider()
            HStack {
                Button("Restore Defaults") { recording = nil; draft = [:] }
                Spacer()
                Button("Cancel") { settings.close() }.keyboardShortcut(.cancelAction)
                Button("Save") { settings.save(draft) }.keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                    .disabled(recording != nil || ShortcutSettings.problem(in: draft) != nil)
            }
        }.padding(24).frame(width: 660).fixedSize()
    }
}

private struct ShortcutRecorder: NSViewRepresentable {
    let chord: ShortcutChord
    let recording: Bool
    let start: () -> Void
    let finish: (ShortcutChord?) -> Void
    func makeNSView(context: Context) -> RecorderButton { RecorderButton() }
    func updateNSView(_ button: RecorderButton, context: Context) {
        button.start = start; button.finish = finish; button.recording = recording
        button.title = recording ? loc("Press keys…") : chord.label
        button.setAccessibilityLabel(recording ? loc("Press a shortcut") : chord.label)
        if recording, button.window?.firstResponder !== button { button.window?.makeFirstResponder(button) }
    }
    final class RecorderButton: NSButton {
        var start: (() -> Void)?
        var finish: ((ShortcutChord?) -> Void)?
        var recording = false
        override var acceptsFirstResponder: Bool { true }
        init() {
            super.init(frame: .zero)
            bezelStyle = .rounded; target = self; action = #selector(beginRecording)
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        @objc private func beginRecording() { window?.makeFirstResponder(self); recording = true; start?() }
        override func performKeyEquivalent(with event: NSEvent) -> Bool {
            guard recording, window?.firstResponder === self else { return super.performKeyEquivalent(with: event) }
            keyDown(with: event); return true
        }
        override func keyDown(with event: NSEvent) {
            guard recording else { super.keyDown(with: event); return }
            let chord = ShortcutChord(event)
            guard chord.key.count == 1 else { NSSound.beep(); return }
            recording = false
            finish?(chord)
            window?.makeFirstResponder(nil)
        }
    }
}
