//
//  CKCaptureManager.swift
//  CKCamera
//
//  Created by Kai Chen on 6/23/22.
//

import Foundation
import AVFoundation

protocol CKCaptureMananging {
    func start(completionHandler: @escaping (Error?) -> Void)
    func stop(completionHandler: @escaping () -> Void)
    func capture(with settings: AVCapturePhotoSettings, completionHandler: @escaping (Result<Data, Error>) -> Void)
}

enum CKCaptureError: Error {
    case unauthorized
    case videoDeviceUnavailable
    case failToAddPhotoOutput
    case noCapturePhoto
    case other(Error)
}

class CKCaptureManager: CKCaptureMananging {

    enum Status {
        case unconfigued
        case authorized
        case configured
        case failed(Error)
    }
    let session = AVCaptureSession()
    
    private var status: Status = .unconfigued
    private let sessionQueue = DispatchQueue(label: "CKCaptureManager.session.queue")    
    private let photoOutput = AVCapturePhotoOutput()
    private var videoDeviceInput: AVCaptureDeviceInput!
    
    // MARK: - Session
    func start(completionHandler: @escaping (Error?) -> Void) {
        requestPermission()
        
        sessionQueue.async {
            if case .failed(let error) = self.status {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                return
            }
            
            self.configureSession()
            
            if !self.session.isRunning {
                self.session.startRunning()
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func stop(completionHandler: @escaping () -> Void) {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
            
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
    
    func requestPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.status = .authorized
                } else {
                    self.status = .failed(CKCaptureError.unauthorized)
                }
                
                self.sessionQueue.resume()
            }
        case .authorized:
            status = .authorized
        default:
            status = .failed(CKCaptureError.unauthorized)
        }
        
    }
    
    func configureSession() {
        guard case .authorized = status else { return }
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        session.sessionPreset = .photo
        
        // Inputs
        do {
            guard let videoDevice = videoDevice(position: .back) else {
                status = .failed(CKCaptureError.videoDeviceUnavailable)
                return
            }
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                videoDevice.videoZoomFactor = videoDevice.preferredZoomFactor
            }
        } catch let error {
            status = .failed(error)
            return
        }
        
        // Outputs
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.maxPhotoQualityPrioritization = .quality
            
            // TODO: Extra AVCapturePhotoOutput settings
        } else {
            status = .failed(CKCaptureError.failToAddPhotoOutput)
        }
     
        status = .configured
    }
    
    private let backVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInTripleCamera, .builtInDualWideCamera, .builtInDualCamera, .builtInWideAngleCamera],
        mediaType: .video,
        position: .back)
    
    private let frontVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInTrueDepthCamera, .builtInWideAngleCamera],
        mediaType: .video,
        position: .front)
    
    private func videoDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        switch position {
        case .front:
            return frontVideoDeviceDiscoverySession.devices.first
        case .unspecified, .back:
            return backVideoDeviceDiscoverySession.devices.first
        @unknown default:
            return AVCaptureDevice.default(for: .video)
        }
    }

    // MARK: - Capture Photo
    private var photoCaptureProcessors: [Int64: CKCapturePhotoCaptureProcessor] = [:]
    
    func capture(with settings: AVCapturePhotoSettings,
                 completionHandler: @escaping (Result<Data, Error>) -> Void) {
        
        let processor = CKCapturePhotoCaptureProcessor(settings: settings) { processor in
            self.sessionQueue.async {
                self.photoCaptureProcessors[processor.settings.uniqueID] = nil
            }
            
            DispatchQueue.main.async {
                if let error = processor.errors.first {
                    completionHandler(.failure(error))
                    return
                }
                
                guard let photoData = processor.photoData else {
                    completionHandler(.failure(CKCaptureError.noCapturePhoto))
                    return
                }
                
                completionHandler(.success(photoData))
            }
        }
        
        sessionQueue.async {
            self.photoCaptureProcessors[settings.uniqueID] = processor
            self.photoOutput.capturePhoto(with: settings, delegate: processor)
        }
        
    }
}

