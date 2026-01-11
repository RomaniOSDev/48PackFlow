//
//  BarcodeScannerView.swift
//  48PackFlow
//
//  Created by Роман Главацкий on 11.01.2026.
//

import SwiftUI
import AVFoundation
import UIKit

struct BarcodeScannerView: View {
    @StateObject private var scannerViewModel: ScannerViewModel
    @ObservedObject var achievementViewModel: AchievementViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showManualEntry = false
    
    init(gearCatalogViewModel: GearCatalogViewModel, achievementViewModel: AchievementViewModel) {
        _scannerViewModel = StateObject(wrappedValue: ScannerViewModel(gearCatalogViewModel: gearCatalogViewModel))
        _achievementViewModel = ObservedObject(wrappedValue: achievementViewModel)
    }
    
    var body: some View {
        ZStack {
            // Camera Preview
            if scannerViewModel.previewLayer != nil {
                CameraPreview(viewModel: scannerViewModel)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }
            
            // Overlay
            VStack {
                Spacer()
                
                // Scanning Frame
                VStack(spacing: 20) {
                    Text("Position barcode within frame")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.appAccent, lineWidth: 3)
                        .frame(width: 250, height: 150)
                        .overlay(
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Image(systemName: "viewfinder")
                                        .foregroundColor(.appAccent)
                                        .font(.title)
                                    Spacer()
                                }
                                Spacer()
                            }
                        )
                }
                
                Spacer()
                
                // Bottom Controls
                HStack(spacing: 30) {
                    Button(action: { showManualEntry = true }) {
                        VStack(spacing: 8) {
                            Image(systemName: "keyboard")
                                .font(.title2)
                            Text("Manual")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        if scannerViewModel.isScanning {
                            scannerViewModel.stopScanning()
                        } else {
                            scannerViewModel.startScanning()
                        }
                    }) {
                        Circle()
                            .fill(scannerViewModel.isScanning ? Color.red : Color.appAccent)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Image(systemName: scannerViewModel.isScanning ? "stop.fill" : "camera.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            )
                    }
                    
                    Button(action: { dismiss() }) {
                        VStack(spacing: 8) {
                            Image(systemName: "xmark")
                                .font(.title2)
                            Text("Close")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(12)
                    }
                }
                .padding(.bottom, 40)
            }
            
            // Scanned Product Alert
            if let product = scannerViewModel.foundProduct {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.appAccent)
                            
                            Text("Product Found")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(product.name)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 16) {
                                Button("Cancel") {
                                    scannerViewModel.foundProduct = nil
                                    scannerViewModel.scannedCode = nil
                                    scannerViewModel.startScanning()
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray)
                                .cornerRadius(10)
                                
                                Button("Add to Catalog") {
                                    scannerViewModel.addScannedProduct()
                                    achievementViewModel.checkScannerProAchievement(scanCount: scannerViewModel.scanCount)
                                    scannerViewModel.startScanning()
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.appAccent)
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(Color.appText)
                        .cornerRadius(20)
                        .padding()
                    )
            }
        }
        .onAppear {
            if scannerViewModel.setupCamera() {
                scannerViewModel.startScanning()
            }
        }
        .onDisappear {
            scannerViewModel.stopScanning()
        }
        .sheet(isPresented: $showManualEntry) {
            ManualBarcodeEntryView(scannerViewModel: scannerViewModel)
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var viewModel: ScannerViewModel
    
    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        if let previewLayer = viewModel.previewLayer {
            previewLayer.frame = uiView.bounds
            if previewLayer.superlayer != uiView.layer {
                uiView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                uiView.layer.addSublayer(previewLayer)
            }
        }
    }
}

class CameraPreviewView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.forEach { $0.frame = bounds }
    }
}

struct ManualBarcodeEntryView: View {
    @ObservedObject var scannerViewModel: ScannerViewModel
    @Environment(\.dismiss) var dismiss
    @State private var barcode = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Enter Barcode") {
                    TextField("Barcode", text: $barcode)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Search") {
                        scannerViewModel.searchProduct(by: barcode)
                        dismiss()
                    }
                    .disabled(barcode.isEmpty)
                }
            }
        }
    }
}
