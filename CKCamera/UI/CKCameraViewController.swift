//
//  CKCameraViewController.swift
//  CKCamera
//
//  Created by Kai Chen on 6/23/22.
//

import UIKit
import AVFoundation

protocol CKCameraViewDelegate: AnyObject {
    func camera(_ viewController: CKCameraViewController, didCapturePhoto photo: UIImage)
    func camera(_ viewController: CKCameraViewController, failToCapturePhoto error: Error)
}

class CKCameraViewController: UIViewController {
    
    @IBOutlet weak var preview: CKCapturePreviewView!
    
    var captureManager: CKCaptureManager!
    weak var delegate: CKCameraViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preview.session = captureManager.session
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        captureManager.start { _ in }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureManager.stop {}
    }
    
    @IBAction func capture(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        settings.photoQualityPrioritization = .quality
        captureManager.capture(with: settings) { [weak self] result in
            guard let ss = self else { return }
            switch result {
            case .failure(let error):
                ss.delegate?.camera(ss, failToCapturePhoto: error)
            case .success(let photoData):
                ss.delegate?.camera(ss, didCapturePhoto: UIImage(data: photoData)!)
            }
        }
    }
    
}
