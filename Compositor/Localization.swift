import Foundation

/// Display names for String-rawValue enums shown in the UI.
///
/// The raw value is the .comp file format's persisted value and must never change;
/// `displayName` looks the same text up in the string catalog so it can be localized,
/// falling back to the raw value (English) when untranslated.
protocol LocalizedDisplayName {}

extension LocalizedDisplayName where Self: RawRepresentable, RawValue == String {
    var displayName: String { String(localized: String.LocalizationValue(rawValue)) }
}

/// Localize a runtime-built English string for display (AppKit titles, alert text,
/// undo names, ternary titles). Untranslated keys return the input unchanged, so
/// wrapping is always safe.
func loc(_ text: String) -> String { String(localized: String.LocalizationValue(text)) }

// MARK: - Document model enums

extension FilterKind: LocalizedDisplayName {}
extension AdjustmentKind: LocalizedDisplayName {}
extension LayerBlendMode: LocalizedDisplayName {}
extension LayerEffectKind: LocalizedDisplayName {}
extension LayerSampling: LocalizedDisplayName {}
extension BackgroundQuality: LocalizedDisplayName {}
extension ShapeKind: LocalizedDisplayName {}
extension GradientStyle: LocalizedDisplayName {}
extension GradientShape: LocalizedDisplayName {}
extension TextAlignment: LocalizedDisplayName {}
extension BrushToolMode: LocalizedDisplayName {}
extension BlurToolMode: LocalizedDisplayName {}
extension SpotHealingMode: LocalizedDisplayName {}
extension WandMode: LocalizedDisplayName {}
extension LassoKind: LocalizedDisplayName {}
extension SelectionMode: LocalizedDisplayName {}
extension EditorSession.SelectionAmountOperation: LocalizedDisplayName {}
extension TrimBasedOn: LocalizedDisplayName {}
extension CanvasUnit: LocalizedDisplayName {}
extension NewCanvasUnit: LocalizedDisplayName {}
extension NewCanvasBackground: LocalizedDisplayName {}
extension GridAppearance.Preset: LocalizedDisplayName {}
extension GridAppearance.Style: LocalizedDisplayName {}
extension DitherStyle: LocalizedDisplayName {}
extension DitherPixelShape: LocalizedDisplayName {}
extension DitherColors: LocalizedDisplayName {}
extension LevelsChannel: LocalizedDisplayName {}
extension LevelsSample: LocalizedDisplayName {}
extension LevelsAuto: LocalizedDisplayName {}
extension HueSampleMode: LocalizedDisplayName {}
extension ColorRange: LocalizedDisplayName {}
extension CameraRawWhiteBalance: LocalizedDisplayName {}
extension CameraRawGlowStyle: LocalizedDisplayName {}
extension CameraRawVignetteStyle: LocalizedDisplayName {}
extension CameraRawScopeMode: LocalizedDisplayName {}
extension CameraRawCurvePage: LocalizedDisplayName {}
extension CameraRawPointChannel: LocalizedDisplayName {}
extension CameraRawMixerPage: LocalizedDisplayName {}
extension CameraRawMixerTab: LocalizedDisplayName {}
extension CameraRawGradePage: LocalizedDisplayName {}
extension CameraRawUprightMode: LocalizedDisplayName {}
extension CameraRawProjection: LocalizedDisplayName {}
extension CameraRawProcessVersion: LocalizedDisplayName {}
