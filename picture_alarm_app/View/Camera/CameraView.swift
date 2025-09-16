import AVFoundation
import UIKit
import SwiftUI
import SwiftData
import ARKit

class CameraViewModel:ObservableObject{
    @Published var faceImage :UIImage?
        @Published var isCameraOn = false
        
        // ARSCNViewへの参照を保持する
        var arScnView: ARSCNView?
}

class CameraViewController: UIViewController,ARSCNViewDelegate,ARSessionDelegate{
    
    var myArSceneView: ARSCNView!
    
    var isShowFace = false
    
    var cameraviewmodel:CameraViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        myArSceneView = ARSCNView()
        
        
        myArSceneView.delegate = self
        myArSceneView.session.delegate = self
        
        myArSceneView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width)
        
//        myArSceneView.showsStatistics = true
//        myArSceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        self.view.addSubview(myArSceneView)
    }

    override func viewDidAppear(_ animated: Bool) {
        let configuration = ARFaceTrackingConfiguration()
        myArSceneView.session.run(configuration)
        
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        myArSceneView.session.pause()
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
        
        // ジオメトリからノードを作成
        let node = SCNNode(geometry: faceGeometry)
        
        DispatchQueue.main.async {
            self.cameraviewmodel?.isCameraOn = true
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
                    // pointOfViewの視錐台（frustum）の内側にノードがいなければ「画面外」と判定
                    let isVisible = myArSceneView.isNode(node, insideFrustumOf: pointOfView)
                    
                    // もし画面外に出ていたら
                    if !isVisible {
                        // セッションからアンカーを削除
                        print("aa")
                        DispatchQueue.main.async {
                            self.cameraviewmodel?.isCameraOn = false
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
