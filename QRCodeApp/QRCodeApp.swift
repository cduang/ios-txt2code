import SwiftUI

/// QRCodeApp - 完全离线的 iOS 二维码工具
///
/// ## 隐私安全承诺
/// - ✅ 零网络访问：不使用 URLSession / 任何第三方网络库
/// - ✅ 所有计算在设备本地完成
/// - ✅ 无数据收集、无追踪、无分析
/// - ✅ 无需用户注册或登录
///
/// ## 最低系统版本
/// - iOS 16.0+ (DataScannerViewController 需求)
@main
struct QRCodeApp: App {

    @State private var showPrivacyNotice = true

    var body: some Scene {
        WindowGroup {
            ContentView()
                .overlay {
                    if showPrivacyNotice {
                        privacyOverlay
                    }
                }
        }
    }

    // MARK: - 隐私声明启动页

    private var privacyOverlay: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("隐私安全")
                    .font(.largeTitle)
                    .bold()

                VStack(alignment: .leading, spacing: 12) {
                    Label("完全离线运行，无需网络", systemImage: "wifi.slash")
                    Label("数据仅存储在您本地设备", systemImage: "iphone")
                    Label("不会收集任何个人信息", systemImage: "hand.raised.fill")
                    Label("无需注册或登录", systemImage: "person.slash")
                }
                .font(.subheadline)

                Button("开始使用") {
                    withAnimation(.easeOut(duration: 0.4)) {
                        showPrivacyNotice = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.top, 12)
            }
            .padding(32)
        }
        .transition(.opacity)
    }
}
