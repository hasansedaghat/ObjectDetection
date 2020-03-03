//
//  TextDetectionViewController.swift
//  ObjectDetection
//
//  Created by Hasan Sedaghat on 1/31/20.
//  Copyright © 2020 SD-University. All rights reserved.
//

import UIKit
import Vision
import CoreMedia

class TextDetectionViewController: UIViewController {

    
    // MARK: - UI Properties
    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var drawingView: DrawingView!
    
    // MARK: - Vision
    var request: VNDetectTextRectanglesRequest?
    
    // MARK: - AV Property
    var videoCapture: VideoCapture!
    
    // MARK: - ViewController LifeCycle
    override func viewDidAppear(_ animated: Bool) {
        setUpModel()
        setUpCamera()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        videoCapture.stop()
    }
    
    // MARK: - Setup Core ML
    func setUpModel() {
        let request = VNDetectTextRectanglesRequest(completionHandler: self.visionRequestDidComplete)
        request.reportCharacterBoxes = true
        self.request = request
    }
    
    // MARK: - SetUp Video
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.setUp(sessionPreset: .hd4K3840x2160) { success in
            
            if success {
                if let previewLayer = self.videoCapture.previewLayer {
                    self.videoPreview.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                self.videoCapture.start()
            }
        }
    }
    
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = videoPreview.bounds
    }
}

// MARK: - VideoCaptureDelegate And Predecation
extension TextDetectionViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        if let pixelBuffer = pixelBuffer {
            self.predictUsingVision(pixelBuffer: pixelBuffer)
        }
    }
    
    func predictUsingVision(pixelBuffer: CVPixelBuffer) {
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        if let request = request {
            try? handler.perform([request])
        }
    }
    // MARK: - Post-processing
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        guard let observations = request.results else {
            return
        }
        
        DispatchQueue.main.async {
            let regions: [VNTextObservation?] = observations.map({$0 as? VNTextObservation})
            self.drawingView.regions = regions
            
        }
    }
}

