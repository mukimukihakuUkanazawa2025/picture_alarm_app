import AVFoundation
import Combine
import UIKit
import SwiftUI
import SwiftData
import ARKit

class CameraViewModel:ObservableObject{
    
    
    static let shared = CameraViewModel()
    
    @Published var faceImage :UIImage?
    @Published var isCameraOn = false
    @Published var isFaceOn = false
    
    // ARSCNViewへの参照を保持する
    var arScnView: ARSCNView?
}

class CameraViewController: UIViewController,ARSCNViewDelegate,ARSessionDelegate{
    
    var myArSceneView: ARSCNView!
    var isShowFace = false
    
    // 3. didSetを追加して、ViewModelが設定されたら監視を開始
    var cameraviewmodel:CameraViewModel? {
        didSet {
            setupBindings()
        }
    }
    
    // 2. 購読管理用のプロパティを追加
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myArSceneView = ARSCNView()
        myArSceneView.delegate = self
        myArSceneView.session.delegate = self
        myArSceneView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width)
        self.view.addSubview(myArSceneView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // isCameraOnがtrueの場合のみセッションを開始するように変更
        if cameraviewmodel?.isCameraOn ?? false {
            let configuration = ARFaceTrackingConfiguration()
            myArSceneView.session.run(configuration)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        myArSceneView.session.pause()
    }
    
    // 4. isCameraOnプロパティを監視するメソッドを追加
    private func setupBindings() {
        cameraviewmodel?.$isCameraOn
            .receive(on: DispatchQueue.main) // UIの更新はメインスレッドで
            .sink { [weak self] isOn in
                guard let self = self else { return }
                
                if isOn {
                    // 必要に応じてセッションを再開するロジック
                    // (viewDidAppearでも実行されるため、ここでは省略可能)
                    print("isCameraOn is true.")
                    let configuration = ARFaceTrackingConfiguration()
                    self.myArSceneView.session.run(configuration)
                } else {
                    // isCameraOnがfalseになったらセッションを停止
                    print("isCameraOn is false. Pausing session.")
                    self.myArSceneView.session.pause()
                }
            }
            .store(in: &cancellables)
    }
    
    // ARSCNViewDelegateのメソッド
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        print("b")
        
        print(anchor)
        // anchorが顔アンカー（ARFaceAnchor）かを確認
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let device = myArSceneView.device else {
            return nil
        }
        
        // 顔のジオメトリを作成
        let faceGeometry = ARSCNFaceGeometry(device: device)!
        
        // ★★★ ここがポイント ★★★
        // マテリアルの描画モードを線（ワイヤーフレーム）に設定する
        faceGeometry.firstMaterial?.fillMode = .lines
        
        faceGeometry.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0)
        
        // ジオメトリからノードを作成
        let node = SCNNode(geometry: faceGeometry)
        
        DispatchQueue.main.async {
            
            self.cameraviewmodel?.isFaceOn = true
            
        }
        
        return node
    }
    
    
    // 3. 毎フレーム更新されるときに呼ばれるデリゲートメソッド
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        // 現在の視点（カメラ）ノードを取得
        guard let pointOfView = myArSceneView.pointOfView else { return }
        
        // 現在フレームに存在するすべてのアンカーをループ
        for anchor in frame.anchors {
            // アンカーに対応するノードを取得
            guard let node = myArSceneView.node(for: anchor) else { continue }
            
            // isNode(_:insideFrustumOf:) を使って、ノードが画面内にいるかチェック
            // pointOfViewの錐台（frustum）の内側にノードがいなければ「画面外」と判定
            let isVisible = myArSceneView.isNode(node, insideFrustumOf: pointOfView)
            
            if !isVisible {
                
                // セッションからアンカーを削除
                
                print("aa")
                
                DispatchQueue.main.async {
                    
                    self.cameraviewmodel?.isFaceOn = false
                    
                }
                
                
                myArSceneView.session.remove(anchor: anchor)
                
            }
            
        }
    }
}


struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var cameraviewmodel : CameraViewModel
    
    @Environment(\.dismiss) var dismiss
    
    // UIViewControllerを作成するメソッド
        func makeUIViewController(context: Context) -> UIViewController {


            let cameraViewController = CameraViewController()
            
            DispatchQueue.main.async {
                        self.cameraviewmodel.arScnView = cameraViewController.myArSceneView
                    }
            
            cameraViewController.cameraviewmodel = cameraviewmodel
            
            
            return cameraViewController
        }

        // UIViewControllerを更新するメソッド
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {

            
        }
    
}
