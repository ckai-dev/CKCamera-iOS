//
//  AVCaptureDevice+PreferredZoomFactor.swift
//  CKCamera
//
//  Created by Kai Chen on 6/23/22.
//

import Foundation
import AVFoundation

extension AVCaptureDevice {
    var preferredZoomFactor: CGFloat {
        switch deviceType {
        case .builtInTripleCamera, .builtInDualWideCamera:
            return 2.0
        default:
            return 1.0
        }
    }
}
