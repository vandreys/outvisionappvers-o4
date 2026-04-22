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
    private let viewId: Int64

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
    private var userLocation: CLLocation?
    // After first GPS fix, wait up to 10 s for good accuracy before forcing placement
    private var locationDeadline: Date?

    init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        self.viewId = viewId
        let params = args as? [String: Any]
        targetLat = params?["lat"] as? Double ?? 0
        targetLng = params?["lng"] as? Double ?? 0
        eyeLevelOffset = params?["eyeLevelOffsetMeters"] as? Double ?? 1.5
        faceUser = params?["faceUser"] as? Bool ?? true
        iosAsset = params?["iosUsdzAsset"] as? String
            ?? params?["androidGlbAsset"] as? String ?? ""

        arView = ARSCNView(frame: frame)
        // 2x MSAA instead of default 4x — halves GPU memory bandwidth for multisampling
        arView.antialiasingMode = .multisampling2X
        // Disable continuous environment probing; we add a fixed light below
        arView.automaticallyUpdatesLighting = false

        eventChannel = FlutterEventChannel(
            name: "outvisionxr/ar_view_events_\(viewId)",
            binaryMessenger: messenger
        )

        super.init()

        arView.delegate = self
        arView.session.delegate = self

        // Manual ambient + directional light — much cheaper than env probing
        let ambientNode = SCNNode()
        ambientNode.light = {
            let l = SCNLight(); l.type = .ambient
            l.color = UIColor(white: 0.7, alpha: 1)
            return l
        }()
        let dirNode = SCNNode()
        dirNode.light = {
            let l = SCNLight(); l.type = .directional
            l.color = UIColor(white: 0.85, alpha: 1)
            return l
        }()
        dirNode.eulerAngles = SCNVector3(-Float.pi / 4, Float.pi / 4, 0)
        arView.scene.rootNode.addChildNode(ambientNode)
        arView.scene.rootNode.addChildNode(dirNode)

        eventChannel.setStreamHandler(self)

        // ARCoachingOverlayView — native ARKit guidance overlay
        let coaching = ARCoachingOverlayView()
        coaching.session = arView.session
        coaching.goal = .tracking
        coaching.activatesAutomatically = true
        coaching.translatesAutoresizingMaskIntoConstraints = false
        arView.addSubview(coaching)
        NSLayoutConstraint.activate([
            coaching.leadingAnchor.constraint(equalTo: arView.leadingAnchor),
            coaching.trailingAnchor.constraint(equalTo: arView.trailingAnchor),
            coaching.topAnchor.constraint(equalTo: arView.topAnchor),
            coaching.bottomAnchor.constraint(equalTo: arView.bottomAnchor),
        ])

        // CoreLocation
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // AR session — gravityAndHeading aligns +X=East, +Y=Up, -Z=North
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
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    // MARK: - ARSessionDelegate

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard case .normal = frame.camera.trackingState else {
            emitStatus("localizing")
            return
        }

        // Model already placed — just keep status current and bail out
        if modelPlaced {
            emitStatus("ready")
            return
        }

        guard let loc = userLocation else {
            emitStatus("localizing")
            return
        }

        let deadlineExpired = locationDeadline.map { Date() > $0 } ?? false
        let accuracyOk = loc.horizontalAccuracy > 0 && loc.horizontalAccuracy <= 20.0

        guard accuracyOk || deadlineExpired else {
            emitStatus("localizing")
            return
        }

        emitStatus("ready")

        if !modelLoading {
            modelLoading = true
            placeArtwork(userLocation: loc)
        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        emitError("AR session error: \(error.localizedDescription)")
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        if userLocation == nil {
            // Start 10 s countdown on first fix
            locationDeadline = Date().addingTimeInterval(10)
        }
        userLocation = loc
    }

    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        NSLog("\(TAG): Location error: \(error.localizedDescription)")
    }

    // MARK: - Place Artwork

    private func placeArtwork(userLocation: CLLocation) {
        let targetLocation = CLLocation(latitude: targetLat, longitude: targetLng)
        let distance = userLocation.distance(from: targetLocation)
        let bearing = bearingBetween(from: userLocation.coordinate,
                                     to: targetLocation.coordinate)

        let bearingRad = bearing * .pi / 180.0
        let position = SCNVector3(
            Float(distance * sin(bearingRad)),
            Float(eyeLevelOffset),
            Float(-distance * cos(bearingRad))
        )

        NSLog("\(TAG): Placing artwork dist=\(String(format:"%.1f",distance))m " +
              "bearing=\(String(format:"%.1f",bearing))°")

        loadModel { [weak self] node in
            guard let self = self, let node = node else {
                self?.emitError("Failed to load 3D model. iOS requires a .usdz file.")
                return
            }
            DispatchQueue.main.async {
                node.position = position

                // SCNBillboardConstraint — hardware-accelerated, replaces per-frame atan2
                if self.faceUser {
                    let billboard = SCNBillboardConstraint()
                    billboard.freeAxes = .Y
                    node.constraints = [billboard]
                }

                self.arView.scene.rootNode.addChildNode(node)
                self.modelPlaced = true
                // GPS no longer needed once the model is anchored
                self.locationManager.stopUpdatingLocation()
                NSLog("\(self.TAG): Artwork placed successfully")
            }
        }
    }

    private func loadModel(completion: @escaping (SCNNode?) -> Void) {
        if iosAsset.hasPrefix("http") {
            guard let url = URL(string: iosAsset) else { completion(nil); return }
            downloadAndLoadModel(from: url, completion: completion)
            return
        }

        let assetKey = FlutterDartProject.lookupKey(forAsset: iosAsset)
        guard let assetURL = Bundle.main.url(forResource: assetKey, withExtension: nil) else {
            NSLog("\(TAG): Could not resolve asset: \(iosAsset)")
            completion(nil)
            return
        }
        loadModelFromURL(assetURL, completion: completion)
    }

    private func downloadAndLoadModel(from url: URL, completion: @escaping (SCNNode?) -> Void) {
        let cacheURL = FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ar_\(url.lastPathComponent)")

        if FileManager.default.fileExists(atPath: cacheURL.path) {
            NSLog("\(TAG): Loading cached model")
            loadModelFromURL(cacheURL, completion: completion)
            return
        }

        NSLog("\(TAG): Downloading model from \(url.lastPathComponent)")
        URLSession.shared.downloadTask(with: url) { [weak self] tempURL, _, error in
            guard let self = self, let tempURL = tempURL, error == nil else {
                NSLog("\(self?.TAG ?? TAG): Download failed: \(error?.localizedDescription ?? "unknown")")
                completion(nil)
                return
            }
            do {
                try? FileManager.default.removeItem(at: cacheURL)
                try FileManager.default.moveItem(at: tempURL, to: cacheURL)
                self.loadModelFromURL(cacheURL, completion: completion)
            } catch {
                NSLog("\(self.TAG): File move failed: \(error)")
                completion(nil)
            }
        }.resume()
    }

    private func loadModelFromURL(_ url: URL, completion: @escaping (SCNNode?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            if let scene = try? SCNScene(url: url, options: nil) {
                let container = SCNNode()
                scene.rootNode.childNodes.forEach { container.addChildNode($0.clone()) }
                completion(container)
                return
            }

            NSLog("\(self.TAG): SCNScene failed, trying MDLAsset...")
            let mdlAsset = MDLAsset(url: url)
            mdlAsset.loadTextures()

            if mdlAsset.count > 0 {
                let container = SCNNode()
                SCNScene(mdlAsset: mdlAsset).rootNode.childNodes.forEach {
                    container.addChildNode($0.clone())
                }
                completion(container)
                return
            }

            NSLog("\(self.TAG): All loaders failed for \(url.lastPathComponent)")
            completion(nil)
        }
    }

    // MARK: - Bearing calculation

    private func bearingBetween(from: CLLocationCoordinate2D,
                                to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let dLng = (to.longitude - from.longitude) * .pi / 180
        let y = sin(dLng) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng)
        return (atan2(y, x) * 180 / .pi + 360).truncatingRemainder(dividingBy: 360)
    }

    // MARK: - Status emission

    private func emitStatus(_ status: String) {
        guard status != lastStatus else { return }
        lastStatus = status
        DispatchQueue.main.async { [weak self] in self?.eventSink?(status) }
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
