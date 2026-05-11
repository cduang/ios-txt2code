import SwiftUI
import UIKit

/// 「生成」标签页的 ViewModel
///
/// 职责：
/// - 管理用户输入的文本
/// - 调用 `QRService` 生成二维码图片
/// - 管理图片保存到相册的流程
@MainActor
final class GenerateViewModel: ObservableObject {

    // MARK: - Published 状态

    /// 用户输入的文本
    @Published var inputText: String = "" {
        didSet { generateQRCode() }
    }

    /// 生成的二维码图片
    @Published var qrCodeImage: UIImage?

    /// 是否正在生成
    @Published var isGenerating: Bool = false

    /// Toast 提示消息
    @Published var toastMessage: String?

    // MARK: - 私有属性

    private var generationTask: Task<Void, Never>?

    // MARK: - 生成二维码

    /// 实时生成二维码（由 `inputText` 的 `didSet` 自动触发）
    func generateQRCode() {
        // 取消上次未完成的任务
        generationTask?.cancel()

        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            qrCodeImage = nil
            return
        }

        isGenerating = true
        generationTask = Task { @MainActor in
            // 轻微延迟，避免输入过程中频繁渲染
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 秒
            guard !Task.isCancelled else { return }

            let image = QRService.generateQRCode(from: inputText)
            guard !Task.isCancelled else { return }

            qrCodeImage = image
            isGenerating = false
        }
    }

    // MARK: - 保存到相册

    /// 将当前二维码保存到相册
    func saveToPhotoLibrary() {
        guard let image = qrCodeImage else {
            toastMessage = "请先生成二维码"
            return
        }

        Task {
            let success = await QRService.saveToPhotoLibrary(image)
            toastMessage = success ? "已保存到相册 ✅" : "保存失败，请检查相册权限"
        }
    }

    // MARK: - 清空

    func clearInput() {
        inputText = ""
        qrCodeImage = nil
    }
}
