import SwiftUI

/// Toast 提示修饰器 - 在屏幕底部显示短暂提示
struct ToastModifier: ViewModifier {

    @Binding var message: String?
    @State private var show: Bool = false

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if show, let msg = message {
                    Text(msg)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.75))
                        .clipShape(Capsule())
                        .padding(.bottom, 32)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    message = nil
                                    show = false
                                }
                            }
                        }
                }
            }
            .onChange(of: message) { _, newValue in
                withAnimation(.spring(duration: 0.3)) {
                    show = newValue != nil
                }
            }
    }
}

extension View {
    /// 显示 Toast 提示
    func toast(message: Binding<String?>) -> some View {
        modifier(ToastModifier(message: message))
    }
}
