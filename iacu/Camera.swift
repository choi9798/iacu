//
//  Camera.swift
//  iacu
//
//  Created by mac on 16/3/2018.
//  Copyright © 2018 lens. All rights reserved.
//

import UIKit
import AVKit

class Camera: ViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var acupoint_position:[Int] = []
    var counter = 0
    var currentMetadata: [AnyObject] = []
    
    let captureSession = AVCaptureSession()
    let faceQueue = DispatchQueue(label: "com.zweigraf.DisplayLiveSamples.faceQueue", attributes: [])
    let opencv = OpenCVWrapper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraON()
    }
    
    func cameraON() {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String : Int(kCVPixelFormatType_32BGRA)]
        output.alwaysDiscardsLateVideoFrames = false
        
        let metaOutput = AVCaptureMetadataOutput()
        metaOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        captureSession.beginConfiguration()
        
        captureSession.addInput(input)
        captureSession.addOutput(output)
        captureSession.addOutput(metaOutput)
        
        captureSession.commitConfiguration()
        
        metaOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.face]
        
        opencv.prepare();
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.isVideoMirrored = true
        if (counter % 5) == 0 {
            if !currentMetadata.isEmpty {
                let boundsArray = currentMetadata
                    .flatMap { $0 as? AVMetadataFaceObject }
                    .map { (faceObject) -> NSValue in
                        let convertedObject = output.transformedMetadataObject(for: faceObject, connection: connection)
                        return NSValue(cgRect: convertedObject!.bounds)
                }
                for i in acupoint_position {
                    opencv.passPosition(Int32(i))
                }
                connection.videoOrientation = AVCaptureVideoOrientation.portrait
                let image = imageFromSampleBuffer(sampleBuffer: sampleBuffer)
                self.imageView.image = opencv.filter(image, inRects: boundsArray)
                
                print("processed pic\n")
                
            } else {
                connection.videoOrientation = AVCaptureVideoOrientation.landscapeRight
                let image = imageFromSampleBuffer(sampleBuffer: sampleBuffer)
                self.imageView.image = image
                print("normal pic\n")
            }
        }
        counter+=1
    }
    
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        currentMetadata = metadataObjects as [AnyObject]
    }
    
    
    func imageFromSampleBuffer(sampleBuffer :CMSampleBuffer) -> UIImage {
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        // イメージバッファのロック
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        // 画像情報を取得
        let base = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)!
        let bytesPerRow = UInt(CVPixelBufferGetBytesPerRow(imageBuffer))
        let width = UInt(CVPixelBufferGetWidth(imageBuffer))
        let height = UInt(CVPixelBufferGetHeight(imageBuffer))
        
        // ビットマップコンテキスト作成
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitsPerCompornent = 8
        let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue) as UInt32)
        let newContext = CGContext(data: base, width: Int(width), height: Int(height), bitsPerComponent: Int(bitsPerCompornent), bytesPerRow: Int(bytesPerRow), space: colorSpace, bitmapInfo: bitmapInfo.rawValue)! as CGContext
        
        // 画像作成
        let imageRef = newContext.makeImage()!
        let image = UIImage(cgImage: imageRef, scale: 1.0, orientation: UIImageOrientation.leftMirrored)
        
        // イメージバッファのアンロック
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        return image
    }
    
    
}
