import UIKit
import CoreImage
@preconcurrency import Vision
import Photos

/// 二维码核心服务 - 完全离线，无任何网络调用
///
/// ## 功能
/// - 生成：使用 `CIQRCodeGenerator` 将字符串转为高清二维码图片
/// - 识别：使用 `VNDetectBarcodesRequest` 从 UIImage 中提取二维码文本
///
/// ## 隐私安全
/// - 不依赖任何网络库
/// - 不发送任何数据到外部
/// - 所有计算在设备本地完成
enum QRService {

    // MARK: - 生成二维码

    /// 将输入文本生成为高清二维码图片
    /// - Parameter text: 需要编码的字符串
    /// - Returns: 高清 `UIImage`，失败时返回 `nil`
    static func generateQRCode(from text: String) -> UIImage? {
        guard !text.isEmpty,
              let data = text.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator")
        else { return nil }

        filter.setValue(data, forKey: "inputMessage")
        // 使用最高的纠错等级 L (Low) 以保证二维码最致密清晰
        filter.setValue("H", forKey: "inputCorrectionLevel")

        guard let ciImage = filter.outputImage else { return nil }

        // 高清晰度缩放：使用 nearest-neighbor 插值避免模糊
        let scale: CGFloat = 10.0  // 放大系数
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let scaledCIImage = ciImage.transformed(by: transform)

        // 转换为 UIImage
        let context = CIContext(options: [.workingColorSpace: NSNull()])
        guard let cgImage = context.createCGImage(scaledCIImage, from: scaledCIImage.extent)
        else { return nil }

        return UIImage(cgImage: cgImage)
    }

    // MARK: - 识别二维码

    /// 从图片中识别二维码文本
    /// - Parameter image: 包含二维码的 UIImage
    /// - Returns: 识别到的文本，失败时返回 `nil`
    static func recognizeQRCode(from image: UIImage) async -> String? {
        guard let cgImage = image.cgImage else { return nil }

        return await withCheckedContinuation { continuation in
            let request = VNDetectBarcodesRequest { request, error in
                guard error == nil else {
                    continuation.resume(returning: nil)
                    return
                }

                let result = request.results?
                    .compactMap { $0 as? VNBarcodeObservation }
                    .first?
                    .payloadStringValue

                continuation.resume(returning: result)
            }

            request.symbologies = [.qr]

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    // MARK: - 保存到相册

    /// 将二维码图片保存到系统相册
    /// - Parameter image: 要保存的 UIImage
    /// - Returns: 成功返回 `.success`，失败返回 `.failure(Error)`
    @discardableResult
    static func saveToPhotoLibrary(_ image: UIImage) async -> Bool {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized || status == .limited else {
                    continuation.resume(returning: false)
                    return
                }

                PHPhotoLibrary.shared().performChanges {
                    PHAssetCreationRequest.creationRequestForAsset(from: image)
                } completionHandler: { success, _ in
                    continuation.resume(returning: success)
                }
            }
        }
    }
}
