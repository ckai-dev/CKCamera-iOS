//
//  CKCapturePreviewView.swift
//  CKCamera
//
//  Created by Kai Chen on 6/23/22.
//

import UIKit
import AVFoundation

protocol CKCapturePreviewing where Self: UIView {}

class CKCapturePreviewView: UIView, CKCapturePreviewing {
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError()
        }
        
        return layer
    }
    
    var session: AVCaptureSession? {
        get {
            return previewLayer.session
        }
        
        set {
            previewLayer.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
