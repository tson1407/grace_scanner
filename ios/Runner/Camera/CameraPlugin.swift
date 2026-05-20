import Flutter
import UIKit

/// Flutter MethodChannel + EventChannel handler for camera operations.
class CameraPlugin: NSObject, FlutterPlugin {
    
    private var cameraManager: CameraManager?
    private var eventSink: FlutterEventSink?
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: "com.scanflow/camera",
            binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: "com.scanflow/camera_stream",
            binaryMessenger: registrar.messenger()
        )
        
        let instance = CameraPlugin()
        instance.cameraManager = CameraManager(textureRegistry: registrar.textures())
        
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let manager = cameraManager else {
            result(FlutterError(code: "NO_MANAGER", message: "Camera manager not initialized", details: nil))
            return
        }
        
        let args = call.arguments as? [String: Any] ?? [:]
        
        switch call.method {
        case "initialize":
            let quality = args["quality"] as? String ?? "high"
            let facing = args["facing"] as? String ?? "back"
            manager.initialize(quality: quality, facing: facing, result: result)
            
        case "startPreview":
            manager.startPreview(result: result)
            
        case "capture":
            let outputPath = args["outputPath"] as? String ?? ""
            manager.capture(outputPath: outputPath, result: result)
            
        case "setFlash":
            let mode = args["mode"] as? String ?? "off"
            manager.setFlash(mode: mode, result: result)
            
        case "setZoom":
            let level = args["level"] as? Double ?? 1.0
            manager.setZoom(level: level, result: result)
            
        case "dispose":
            manager.dispose()
            result(["success": true])
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

// MARK: - FlutterStreamHandler (EventChannel)
extension CameraPlugin: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        cameraManager?.setFrameEventSink(events)
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        cameraManager?.setFrameEventSink(nil)
        return nil
    }
}
