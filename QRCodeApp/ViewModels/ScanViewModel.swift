import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// 「扫描」标签页的 ViewModel
///
/// 职责：
/// - 管理相机扫码（`DataScannerViewController` / `AVCaptureSession`）
/// - 管理相册图片识别（`PHPickerViewController`）
/// - 识别结果复制到剪贴板
@MainActor
final class ScanViewModel: ObservableObject {

    // MARK: - Published 状态

    /// 识别出的文本
    @Published var scannedText: String?

    /// 是否显示相机扫描器
    @Published var isShowingScanner: Bool = false

    /// 是否显示相册选择器
    @Published var isShowingImagePicker: Bool = false

    /// 是否正在识别
    @Published var isRecognizing: Bool = false

    /// Toast 提示消息
    @Published var toastMessage: String?

    /// 历史识别记录
    @Published var scanHistory: [QRCodeResult] = []

    // MARK: - 扫描结果处理

    /// 处理相机扫码结果
    func handleScanResult(_ text: String) {
        scannedText = text
        addToHistory(text)
        isShowingScanner = false
        toastMessage = "识别成功 ✅"
    }

    /// 处理相册图片识别结果
    func handleImageRecognition(_ image: UIImage) {
        isRecognizing = true

        Task {
            let result = await QRService.recognizeQRCode(from: image)
            isRecognizing = false
            isShowingImagePicker = false

            if let text = result {
                scannedText = text
                addToHistory(text)
                toastMessage = "识别成功 ✅"
            } else {
                toastMessage = "未识别到二维码"
            }
        }
    }

    // MARK: - 复制到剪贴板

    /// 将识别结果复制到系统剪贴板
    func copyToClipboard() {
        guard let text = scannedText, !text.isEmpty else { return }
        UIPasteboard.general.string = text
        toastMessage = "已复制到剪贴板 📋"
    }

    // MARK: - 清空结果

    func clearResult() {
        scannedText = nil
    }

    // MARK: - 私有多方法

    private func addToHistory(_ text: String) {
        // 避免重复添加完全相同的记录
        if scanHistory.first?.text != text {
            scanHistory.insert(QRCodeResult(text: text), at: 0)
        }
    }
}
