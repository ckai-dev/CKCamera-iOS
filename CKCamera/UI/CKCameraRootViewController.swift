//
//  CKCameraRootViewController.swift
//  CKCamera
//
//  Created by Kai Chen on 6/23/22.
//

import UIKit

class CKCameraRootViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(openCamera(_:)))
        ]
        view.backgroundColor = .white
    }
    
    @objc func openCamera(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "openCamera", sender: sender)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case "openCamera":
            guard let viewController = segue.destination as? CKCameraViewController else {
                return
            }
            viewController.modalPresentationStyle = .fullScreen
            
            // TODO: Refactor into more elegant pattern
            viewController.captureManager = CKCaptureManager()
            viewController.delegate = self
        default:
            break
        }
    }

}

extension CKCameraRootViewController: CKCameraViewDelegate {
    func camera(_ viewController: CKCameraViewController, didCapturePhoto photo: UIImage) {
        imageView.image = photo
        viewController.dismiss(animated: true)
    }
    
    func camera(_ viewController: CKCameraViewController, failToCapturePhoto error: Error) {
        imageView.image = nil
        viewController.dismiss(animated: true)
    }
    
    
}

