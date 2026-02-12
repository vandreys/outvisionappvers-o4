import Flutter
import UIKit
import ARKit
import CoreLocation
import SceneKit

class ArPlatformView: NSObject, FlutterPlatformView, FlutterStreamHandler,
                      ARSCNViewDelegate, ARSessionDelegate, CLLocationManagerDelegate {

    private let TAG = "OutvisionXR-AR"

    private let arView: ARSCNView
    private let eventChannel: FlutterEventChannel
    private var eventSink: FlutterEventSink?
    private let locationManager = CLLocationManager()

    // Creation params
    private let targetLat: Double
    private let targetLng: Double
    private let eyeLevelOffset: Double
    private let faceUser: Bool
    private let iosAsset: String

    // State
    private var lastStatus: String?
    private var modelPlaced = false
    private var modelLoading = false
    private var modelNode: SCNNode?
    private var userLocation: CLLocation?

    init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        let params = args as? [String: Any]
        targetLat = params?["lat"] as? Double ?? 0
        targetLng = params?["lng"] as? Double ?? 0
        eyeLevelOffset = params?["eyeLevelOffsetMeters"] as? Double ?? 1.5
        faceUser = params?["faceUser"] as? Bool ?? true
        iosAsset = params?["iosUsdzAsset"] as? String
            ?? params?["androidGlbAsset"] as? String ?? ""

        arView = ARSCNView(frame: frame)
        eventChannel = FlutterEventChannel(
            name: "outvisionxr/ar_view_events_\(viewId)",
            binaryMessenger: messenger
        )

        super.init()

        arView.delegate = self
        arView.session.delegate = self
        arView.automaticallyUpdatesLighting = true

        eventChannel.setStreamHandler(self)

        // Start CoreLocation
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()

        // Start AR session — gravityAndHeading aligns AR world with compass
        // +X = East, +Y = Up, -Z = North
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravityAndHeading
        arView.session.run(config)

        NSLog("\(TAG): init viewId=\(viewId) lat=\(targetLat) lng=\(targetLng) asset=\(iosAsset)")
    }

    func view() -> UIView { arView }

    // MARK: - FlutterStreamHandler

    func onListen(withArguments arguments: Any?,
                  eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        emitStatus("localizing")
        NSLog("\(TAG): AR event stream started")
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    // MARK: - ARSessionDelegate

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        switch frame.camera.trackingState {
        case .normal:
            guard let loc = userLocation, loc.horizontalAccuracy <= 20.0 else {
                emitStatus("localizing")
                return
            }

            emitStatus("ready")

            if !modelPlaced && !modelLoading {
                modelLoading = true
                placeArtwork(userLocation: loc)
            }

            if faceUser, let node = modelNode {
                applyBillboard(node: node, camera: frame.camera)
            }

        case .notAvailable, .limited:
            emitStatus("localizing")

        @unknown default:
            break
        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        emitError("AR session error: \(error.localizedDescription)")
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        userLocation = loc
    }

    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        NSLog("\(TAG): Location error: \(error.localizedDescription)")
    }

    // MARK: - Place Artwork

    private func placeArtwork(userLocation: CLLocation) {
        let targetLocation = CLLocation(latitude: targetLat, longitude: targetLng)

        // Calculate distance and bearing from user to target
        let distance = userLocation.distance(from: targetLocation)
        let bearing = bearingBetween(
            from: userLocation.coordinate,
            to: targetLocation.coordinate
        )

        // Convert bearing + distance to AR world coordinates
        let bearingRad = bearing * .pi / 180.0
        let dx = Float(distance * sin(bearingRad))    // East
        let dz = Float(-distance * cos(bearingRad))   // North (ARKit -Z = North)
        let dy = Float(eyeLevelOffset)

        let position = SCNVector3(dx, dy, dz)

        NSLog("\(TAG): Placing artwork at dx=\(dx) dy=\(dy) dz=\(dz) " +
              "distance=\(String(format: "%.1f", distance))m " +
              "bearing=\(String(format: "%.1f", bearing))°")

        loadModel { [weak self] node in
            guard let self = self else { return }
            guard let node = node else {
                self.emitError("Failed to load 3D model. " +
                               "iOS requires a .usdz file (not .glb).")
                return
            }

            DispatchQueue.main.async {
                node.position = position
                self.arView.scene.rootNode.addChildNode(node)
                self.modelNode = node
                self.modelPlaced = true
                NSLog("\(self.TAG): Artwork placed successfully")
            }
        }
    }

    private func loadModel(completion: @escaping (SCNNode?) -> Void) {
        let assetKey = FlutterDartProject.lookupKey(forAsset: iosAsset)

        guard let assetURL = Bundle.main.url(forResource: assetKey,
                                             withExtension: nil) else {
            NSLog("\(TAG): Could not resolve asset: \(iosAsset) (key: \(assetKey))")
            completion(nil)
            return
        }

        NSLog("\(TAG): Loading model from \(assetURL.lastPathComponent)")

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            // Try SCNScene first (supports .scn, .dae, .usdz, .obj)
            if let scene = try? SCNScene(url: assetURL, options: [
                .checkConsistency: true
            ]) {
                let container = SCNNode()
                for child in scene.rootNode.childNodes {
                    container.addChildNode(child.clone())
                }
                completion(container)
                return
            }

            NSLog("\(self.TAG): SCNScene failed, trying MDLAsset...")

            // Fallback: MDLAsset (supports .usdz, .obj, .ply, .stl, .abc)
            let mdlAsset = MDLAsset(url: assetURL)
            mdlAsset.loadTextures()

            if mdlAsset.count > 0 {
                let scene = SCNScene(mdlAsset: mdlAsset)
                let container = SCNNode()
                for child in scene.rootNode.childNodes {
                    container.addChildNode(child.clone())
                }
                completion(container)
                return
            }

            NSLog("\(self.TAG): All loaders failed for \(assetURL.lastPathComponent)")
            completion(nil)
        }
    }

    // MARK: - Billboard (face user)

    private func applyBillboard(node: SCNNode, camera: ARCamera) {
        let camPos = camera.transform.columns.3
        let objPos = node.simdPosition

        let dx = camPos.x - objPos.x
        let dz = camPos.z - objPos.z
        let yaw = atan2(dx, dz)

        node.simdEulerAngles = SIMD3<Float>(0, yaw, 0)
    }

    // MARK: - Bearing calculation

    private func bearingBetween(from: CLLocationCoordinate2D,
                                to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let dLng = (to.longitude - from.longitude) * .pi / 180

        let y = sin(dLng) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng)

        let bearing = atan2(y, x) * 180 / .pi
        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }

    // MARK: - Status emission

    private func emitStatus(_ status: String) {
        guard status != lastStatus else { return }
        lastStatus = status
        DispatchQueue.main.async { [weak self] in
            self?.eventSink?(status)
        }
    }

    private func emitError(_ message: String) {
        lastStatus = "error"
        NSLog("\(TAG): ERROR: \(message)")
        DispatchQueue.main.async { [weak self] in
            self?.eventSink?(["status": "error", "message": message])
        }
    }

    // MARK: - Cleanup

    deinit {
        NSLog("\(TAG): deinit")
        arView.session.pause()
        locationManager.stopUpdatingLocation()
        eventSink = nil
    }
}
