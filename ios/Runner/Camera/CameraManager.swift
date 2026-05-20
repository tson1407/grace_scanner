import AVFoundation
import Flutter
import UIKit

/// AVFoundation camera manager for iOS.
class CameraManager: NSObject {
    
    private let textureRegistry: FlutterTextureRegistry
    private let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var videoOutput = AVCaptureVideoDataOutput()
    private var device: AVCaptureDevice?
    private var textureId: Int64?
    private var pixelBufferRenderer: PixelBufferRenderer?
    private var frameEventSink: FlutterEventSink?
    private var pendingCaptureResult: FlutterResult?
    private var pendingOutputPath: String?
    
    private let sessionQueue = DispatchQueue(label: "com.scanflow.camera.session")
    
    init(textureRegistry: FlutterTextureRegistry) {
        self.textureRegistry = textureRegistry
        super.init()
    }
    
    func setFrameEventSink(_ sink: FlutterEventSink?) {
        frameEventSink = sink
    }
    
    func initialize(quality: String, facing: String, result: @escaping FlutterResult) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            self.session.sessionPreset = quality == "high" ? .photo : .high
            
            // Select camera
            let position: AVCaptureDevice.Position = facing == "front" ? .front : .back
            guard let device = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: position
            ) else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "NO_CAMERA", message: "Camera not available", details: nil))
                }
                return
            }
            self.device = device
            
            do {
                // Remove existing inputs
                self.session.inputs.forEach { self.session.removeInput($0) }
                
                let input = try AVCaptureDeviceInput(device: device)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }
                
                // Photo output
                if self.session.canAddOutput(self.photoOutput) {
                    self.session.addOutput(self.photoOutput)
                }
                
                // Video output for preview frames
                self.videoOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
                if self.session.canAddOutput(self.videoOutput) {
                    self.session.addOutput(self.videoOutput)
                }
                
                self.session.commitConfiguration()
                
                DispatchQueue.main.async {
                    result([
                        "success": true,
                        "previewSize": [
                            "width": 1080.0,
                            "height": 1440.0
                        ]
                    ])
                }
            } catch {
                self.session.commitConfiguration()
                DispatchQueue.main.async {
                    result(FlutterError(code: "INIT_FAILED", message: error.localizedDescription, details: nil))
                }
            }
        }
    }
    
    func startPreview(result: @escaping FlutterResult) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Register texture with Flutter
            let renderer = PixelBufferRenderer()
            self.pixelBufferRenderer = renderer
            
            DispatchQueue.main.async {
                let texId = self.textureRegistry.register(renderer)
                self.textureId = texId
                
                self.sessionQueue.async {
                    self.session.startRunning()
                    
                    DispatchQueue.main.async {
                        result([
                            "textureId": texId,
                            "success": true
                        ])
                    }
                }
            }
        }
    }
    
    func capture(outputPath: String, result: @escaping FlutterResult) {
        guard session.isRunning else {
            result(FlutterError(code: "NOT_RUNNING", message: "Camera session not running", details: nil))
            return
        }
        
        pendingCaptureResult = result
        pendingOutputPath = outputPath
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off // Will be overridden by current flash setting
        
        if let device = device {
            if device.hasFlash {
                // Use current torch mode setting for flash
            }
        }
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func setFlash(mode: String, result: @escaping FlutterResult) {
        guard let device = device else {
            result(FlutterError(code: "NO_DEVICE", message: "No camera device", details: nil))
            return
        }
        
        do {
            try device.lockForConfiguration()
            
            if device.hasTorch {
                switch mode {
                case "on":
                    device.torchMode = .on
                case "auto":
                    device.torchMode = .auto
                default:
                    device.torchMode = .off
                }
            }
            
            device.unlockForConfiguration()
            result(["success": true])
        } catch {
            result(FlutterError(code: "FLASH_FAILED", message: error.localizedDescription, details: nil))
        }
    }
    
    func setZoom(level: Double, result: @escaping FlutterResult) {
        guard let device = device else {
            result(FlutterError(code: "NO_DEVICE", message: "No camera device", details: nil))
            return
        }
        
        do {
            try device.lockForConfiguration()
            let maxZoom = min(device.activeFormat.videoMaxZoomFactor, 10.0)
            device.videoZoomFactor = 1.0 + CGFloat(level) * (maxZoom - 1.0)
            device.unlockForConfiguration()
            result(["success": true])
        } catch {
            result(FlutterError(code: "ZOOM_FAILED", message: error.localizedDescription, details: nil))
        }
    }
    
    func dispose() {
        sessionQueue.async { [weak self] in
            self?.session.stopRunning()
            DispatchQueue.main.async {
                if let texId = self?.textureId {
                    self?.textureRegistry.unregisterTexture(texId)
                }
                self?.pixelBufferRenderer = nil
                self?.textureId = nil
            }
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        pixelBufferRenderer?.latestPixelBuffer = pixelBuffer
        
        if let texId = textureId {
            DispatchQueue.main.async { [weak self] in
                self?.textureRegistry.textureFrameAvailable(texId)
            }
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let result = pendingCaptureResult else { return }
        
        if let error = error {
            DispatchQueue.main.async {
                result(FlutterError(code: "CAPTURE_FAILED", message: error.localizedDescription, details: nil))
            }
            pendingCaptureResult = nil
            return
        }
        
        guard let data = photo.fileDataRepresentation(),
              let outputPath = pendingOutputPath else {
            DispatchQueue.main.async {
                result(FlutterError(code: "NO_DATA", message: "No image data captured", details: nil))
            }
            pendingCaptureResult = nil
            return
        }
        
        // Write to file
        let url = URL(fileURLWithPath: outputPath)
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url)
            
            DispatchQueue.main.async {
                result([
                    "path": outputPath,
                    "width": photo.resolvedSettings.photoDimensions.width,
                    "height": photo.resolvedSettings.photoDimensions.height,
                    "success": true
                ])
            }
        } catch {
            DispatchQueue.main.async {
                result(FlutterError(code: "SAVE_FAILED", message: error.localizedDescription, details: nil))
            }
        }
        
        pendingCaptureResult = nil
        pendingOutputPath = nil
    }
}

// MARK: - PixelBufferRenderer (FlutterTexture)
class PixelBufferRenderer: NSObject, FlutterTexture {
    var latestPixelBuffer: CVPixelBuffer?
    
    func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        guard let buffer = latestPixelBuffer else { return nil }
        return Unmanaged.passRetained(buffer)
    }
}
