//
//  ViewController.swift
//  SimpleCamera
//
//  Created by Simon Ng on 25/11/14.
//  Copyright (c) 2014 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var backFacingCamera: AVCaptureDevice?
    var frontFacingCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    var stillImageOutput: AVCaptureStillImageOutput?
    var stillImage: UIImage?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var toggleCameraGestureRecognizer = UISwipeGestureRecognizer()
    var zoomInGestureRecognizer = UISwipeGestureRecognizer()
    var zoomOutGestureRecognizer = UISwipeGestureRecognizer()
    
    @IBOutlet weak var cameraButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // preset the session for taking photos in full resolution
        
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as! [AVCaptureDevice]
        
        // get the front and back cameras for taking photos
        
        for device in devices {
            if device.position == AVCaptureDevicePosition.Back {
                backFacingCamera = device
            } else if device.position == AVCaptureDevicePosition.Front {
                frontFacingCamera = device
            }
        }
        
        currentDevice = backFacingCamera
        
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice)
            
            // configure the session with the output for capturing still images
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]

            
            // configure the session with the input and output devices
            
            captureSession.addInput(captureDeviceInput)
            captureSession.addOutput(stillImageOutput)
            
        } catch {
            print(error)
        }
        
        // provide a camera preview
        
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        cameraPreviewLayer?.frame = view.layer.frame
        
        // bring the camera button to front
        
        view.bringSubviewToFront(cameraButton)
        captureSession.startRunning()
        
        // toggle camera swipe recognizer
        
        toggleCameraGestureRecognizer.direction = .Up
        toggleCameraGestureRecognizer.addTarget(self, action: "toggleCamera")
        view.addGestureRecognizer(toggleCameraGestureRecognizer)
        
        // zoom in recognizer
        
        zoomInGestureRecognizer.direction = .Right
        zoomInGestureRecognizer.addTarget(self, action: "zoomIn")
        view.addGestureRecognizer(zoomInGestureRecognizer)
        
        // zoom out recognizer
        
        zoomOutGestureRecognizer.direction = .Left
        zoomOutGestureRecognizer.addTarget(self, action: "zoomOut")
        view.addGestureRecognizer(zoomOutGestureRecognizer)

    }

    @IBAction func unwindToCamera(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func capture(sender: AnyObject) {
        let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo)
        stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageDataSampleBuffer, error) -> Void in
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
            self.stillImage = UIImage(data: imageData)
            self.performSegueWithIdentifier("showPhoto", sender: self)
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // get the new view controller by using segue.destinationViewController and pass the selected object to the new view controller
        
        if segue.identifier == "showPhoto" {
            let photoViewController = segue.destinationViewController as! PhotoViewController
            photoViewController.image = stillImage
        }
    }
    
    func toggleCamera() {
        captureSession.beginConfiguration()
        
        // change the device based on the current camera
        
        let newDevice = (currentDevice?.position == AVCaptureDevicePosition.Back) ? frontFacingCamera : backFacingCamera
        
        // remove all inputs from the session
        
        for input in captureSession.inputs {
            captureSession.removeInput(input as! AVCaptureDeviceInput)
        }
        
        // change to the new input
        
        let cameraInput: AVCaptureDeviceInput
        do {
            cameraInput = try AVCaptureDeviceInput(device: newDevice)
        } catch {
            print(error)
            return
        }
        
        if captureSession.canAddInput(cameraInput) {
            captureSession.addInput(cameraInput)
        }
        
        currentDevice = newDevice
        captureSession.commitConfiguration()
    }
    
    func zoomIn() {
        if let zoomFactor = currentDevice?.videoZoomFactor {
            if zoomFactor < 5 {
                let newZoomFactor = min(zoomFactor + 1.0, 5.0)
                do {
                    try currentDevice?.lockForConfiguration()
                    currentDevice?.rampToVideoZoomFactor(newZoomFactor, withRate: 1.0)
                    currentDevice?.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func zoomOut() {
        if let zoomFactor = currentDevice?.videoZoomFactor {
            if zoomFactor > 1.0 {
                let newZoomFactor = max(zoomFactor - 1.0, 1.0)
                do {
                    try currentDevice?.lockForConfiguration()
                    currentDevice?.rampToVideoZoomFactor(newZoomFactor, withRate: 1.0)
                    currentDevice?.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
        }
    }
    
}

    