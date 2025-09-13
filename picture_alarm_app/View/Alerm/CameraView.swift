import SwiftUI
import Vision
//import SDSNSUIBridge
//import SDSVisionExtension

struct CameraView: View {
    let imageNames = ["Child01", "Child02", "Family01", "Family02", "Man01", "Man02", "Woman01", "Woman02"]
    @State var imageName = "Child01"

    @State var faces: [FaceObservation] = []

    var body: some View {
        VStack {
            Image(imageName)
                .resizable().scaledToFit()
                .visionRectangles(faces)
                .frame(height: 600)
            HStack {
                Picker(selection: $imageName, content: {
                    ForEach(imageNames, id: \.self) { name in
                        Text(name).tag(name)
                    }
                }, label: { Text("Photo selector") }).fixedSize()
                    .onChange(of: imageName, {
                        faces = []
                    })
                Button(action: {
                    Task { @MainActor in
                        try await detectFaces()
                    }

                }, label: { Text("Detect") })
            }
        }
        .padding()
    }

    func detectFaces() async throws {
        let detectFaceRequest = DetectFaceRectanglesRequest()
        guard let cgImage = imageCGImage else { return }

        let handler = ImageRequestHandler(cgImage)

        let faceObservations = try await handler.perform(detectFaceRequest)

        faces = faceObservations
    }

    var imageCGImage: CGImage? {
        return NSUIImage(named: imageName)?.toCGImage
    }

    func detectFaceParts() async throws {
        var detectFaceRequest = DetectFaceLandmarksRequest()
        detectFaceRequest.inputFaceObservations = faces
        guard let cgImage = imageCGImage else { return }

        let handler = ImageRequestHandler(cgImage)

        let faceObservations = try await handler.perform(detectFaceRequest)

        faces = faceObservations
    }
}
