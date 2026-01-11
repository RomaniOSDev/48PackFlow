//
//  ScannerViewModel.swift
//  48PackFlow
//
//  Created by Роман Главацкий on 11.01.2026.
//

import Foundation
import AVFoundation
import Combine
import AudioToolbox

class ScannerViewModel: NSObject, ObservableObject {
    @Published var scannedCode: String?
    @Published var isScanning: Bool = false
    @Published var showManualEntry: Bool = false
    @Published var foundProduct: GearItem?
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    
    var captureSession: AVCaptureSession?
    
    private let gearCatalogViewModel: GearCatalogViewModel
    private let userDefaults = UserDefaults.standard
    private let scanCountKey = "scanCount"
    
    var scanCount: Int {
        userDefaults.integer(forKey: scanCountKey)
    }
    
    init(gearCatalogViewModel: GearCatalogViewModel) {
        self.gearCatalogViewModel = gearCatalogViewModel
        super.init()
    }
    
    func setupCamera() -> Bool {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return false
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return false
        }
        
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession else { return false }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return false
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean13, .ean8, .code128]
        } else {
            return false
        }
        
        // Create preview layer
        let preview = AVCaptureVideoPreviewLayer(session: captureSession)
        preview.videoGravity = .resizeAspectFill
        previewLayer = preview
        
        return true
    }
    
    func startScanning() {
        guard let captureSession = captureSession else { return }
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
            }
            isScanning = true
        }
    }
    
    func stopScanning() {
        captureSession?.stopRunning()
        isScanning = false
    }
    
    func searchProduct(by barcode: String) {
        // Mock search - in real app, this would call an API
        // For now, we'll create a placeholder item
        foundProduct = GearItem(
            name: "Product \(barcode)",
            category: .other,
            lastUsedDate: Date()
        )
    }
    
    func addScannedProduct() {
        guard let product = foundProduct else { return }
        gearCatalogViewModel.addGearItem(product)
        
        // Update scan count
        let currentCount = userDefaults.integer(forKey: scanCountKey)
        userDefaults.set(currentCount + 1, forKey: scanCountKey)
        
        scannedCode = nil
        foundProduct = nil
    }
}

extension ScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            scannedCode = stringValue
            stopScanning()
            searchProduct(by: stringValue)
        }
    }
}
