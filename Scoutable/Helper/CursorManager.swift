import SwiftUI
import UIKit

/// A manager class that handles cursor-like interactions for iOS SwiftUI views
/// This provides similar functionality to cursor management but adapted for touch interfaces
class CursorManager: ObservableObject {
    static let shared = CursorManager()
    
    @Published var currentCursorStyle: CursorStyle = .default
    @Published var isHovering = false
    
    private init() {}
    
    /// Different cursor styles available for iOS
    enum CursorStyle {
        case `default`
        case pointingHand
        case textInput
        case selection
        case resize
        case custom(UIImage)
        
        var systemImage: String? {
            switch self {
            case .default:
                return nil
            case .pointingHand:
                return "hand.point.up"
            case .textInput:
                return "textformat"
            case .selection:
                return "crosshair"
            case .resize:
                return "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"
            case .custom:
                return nil
            }
        }
    }
    
    /// Sets the cursor style for the current view
    /// - Parameter style: The CursorStyle to display
    func setCursorStyle(_ style: CursorStyle) {
        currentCursorStyle = style
    }
    
    /// Resets the cursor to the default style
    func resetCursor() {
        currentCursorStyle = .default
    }
    
    /// Sets a pointing hand cursor (useful for clickable elements)
    func setPointingHandCursor() {
        setCursorStyle(.pointingHand)
    }
    
    /// Sets a text input cursor (useful for text input areas)
    func setTextInputCursor() {
        setCursorStyle(.textInput)
    }
    
    /// Sets a selection cursor (useful for selection tools)
    func setSelectionCursor() {
        setCursorStyle(.selection)
    }
    
    /// Sets a resize cursor (useful for resizable elements)
    func setResizeCursor() {
        setCursorStyle(.resize)
    }
    
    /// Creates a custom cursor from an image
    /// - Parameter image: The UIImage to use as the cursor
    /// - Returns: A custom CursorStyle
    func createCustomCursor(from image: UIImage) -> CursorStyle {
        return .custom(image)
    }
}

/// A SwiftUI view modifier that applies cursor-like styling for iOS
struct CursorModifier: ViewModifier {
    let cursorStyle: CursorManager.CursorStyle
    @StateObject private var cursorManager = CursorManager.shared
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                cursorManager.setCursorStyle(cursorStyle)
            }
            .onDisappear {
                cursorManager.resetCursor()
            }
    }
}

/// A SwiftUI view modifier that applies cursor-like styling with hover detection
struct HoverCursorModifier: ViewModifier {
    let cursorStyle: CursorManager.CursorStyle
    @StateObject private var cursorManager = CursorManager.shared
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        content
            .onHover { hovering in
                isHovered = hovering
                if hovering {
                    cursorManager.setCursorStyle(cursorStyle)
                } else {
                    cursorManager.resetCursor()
                }
            }
    }
}

/// A SwiftUI view modifier that shows a visual indicator for interactive elements
struct InteractiveIndicatorModifier: ViewModifier {
    let style: CursorManager.CursorStyle
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .onTapGesture {
                // Handle tap if needed
            }
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
            .overlay(
                Group {
                    if let systemImage = style.systemImage {
                        Image(systemName: systemImage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .opacity(isPressed ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.1), value: isPressed)
                    }
                }
            )
    }
}

/// Extension to add cursor modifiers to SwiftUI views
extension View {
    /// Applies a cursor-like style to the view
    /// - Parameter style: The CursorStyle to display
    /// - Returns: A view with the cursor style applied
    func cursor(_ style: CursorManager.CursorStyle) -> some View {
        modifier(CursorModifier(cursorStyle: style))
    }
    
    /// Applies a cursor-like style that only shows on hover
    /// - Parameter style: The CursorStyle to display on hover
    /// - Returns: A view with the hover cursor applied
    func hoverCursor(_ style: CursorManager.CursorStyle) -> some View {
        modifier(HoverCursorModifier(cursorStyle: style))
    }
    
    /// Applies a pointing hand cursor on hover (for clickable elements)
    func clickable() -> some View {
        hoverCursor(.pointingHand)
    }
    
    /// Applies a text input cursor (for text input areas)
    func textInput() -> some View {
        cursor(.textInput)
    }
    
    /// Applies a selection cursor (for selection tools)
    func selectable() -> some View {
        cursor(.selection)
    }
    
    /// Applies a resize cursor (for resizable elements)
    func resizable() -> some View {
        cursor(.resize)
    }
    
    /// Applies an interactive indicator for touch devices
    /// - Parameter style: The CursorStyle to use for the indicator
    /// - Returns: A view with interactive feedback
    func interactive(_ style: CursorManager.CursorStyle = .pointingHand) -> some View {
        modifier(InteractiveIndicatorModifier(style: style))
    }
    
    /// Makes a view clickable with visual feedback
    func clickableWithFeedback() -> some View {
        interactive(.pointingHand)
    }
} 