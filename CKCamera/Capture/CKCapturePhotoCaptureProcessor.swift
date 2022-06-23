//
//  CKCapturePhotoCaptureProcessor.swift
//  CKCamera
//
//  Created by Kai Chen on 6/23/22.
//

import Foundation
import AVFoundation

class CKCapturePhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
    
    let settings: AVCapturePhotoSettings
    private(set) var errors: [Error] = []
    
    private let completionHandler: (CKCapturePhotoCaptureProcessor) -> Void
    
    var photoData: Data?
        
    init(settings: AVCapturePhotoSettings,
         completionHandler: @escaping (CKCapturePhotoCaptureProcessor) -> Void) {
        self.settings = settings
        self.completionHandler = completionHandler
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            errors.append(error)
            return
        }
        
        photoData = photo.fileDataRepresentation()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error = error {
            errors.append(error)
        }
        
        completionHandler(self)
    }
}
