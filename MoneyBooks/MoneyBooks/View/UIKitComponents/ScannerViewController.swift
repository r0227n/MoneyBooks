//
//  ScannerViewController.swift
//  SwiftUI-BarcodeScanner
//
//  Created by Mike Jarosch on 11/27/20.
//

import UIKit
import AVFoundation

enum CameraError {
    case InvalidDeviceInput
    case invalidScannedValue
}

protocol ScannerViewControllerDelegate : class {
    func didFind(barcode: String)  // ScannerView.swiftでscannedCodeに値をbarcode引数の値を代入するよ
    //func didSurface(error: CameraError)
}

final class ScannerViewController : UIViewController {
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    weak var scannerDelegate: ScannerViewControllerDelegate?
    
    init(scannerDelegate: ScannerViewControllerDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.scannerDelegate = scannerDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let previewLayer = previewLayer else {
            //scannerDelegate?.didSurface(error: .InvalidDeviceInput)
            return
        }
        previewLayer.frame = view.layer.bounds
    }
    
    private func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            //scannerDelegate?.didSurface(error: .InvalidDeviceInput)
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            try videoInput = AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            //scannerDelegate?.didSurface(error: .InvalidDeviceInput)
            return
        }
        
        if captureSession.canAddInput(videoInput) {   // canAddInput() : 特定の入力セッションに追加できるかどうかをbool値で返す。
            captureSession.addInput(videoInput)  // セッションに追加
        } else {
            //scannerDelegate?.didSurface(error: .InvalidDeviceInput)
            return
        }
        
        let metaDataOutput = AVCaptureMetadataOutput() // 指定されたメタデータを検出し、その処理のためにデリゲートを転送する
        
        if captureSession.canAddOutput(metaDataOutput) { // canAddOutput() : 特定の出力セッションに追加できるかどうかをbool値で返す。
            captureSession.addOutput(metaDataOutput)
            
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //metaDataOutput.metadataObjectTypes = [.ean8, .ean13]
            metaDataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.ean13]
        } else {
            //scannerDelegate?.didSurface(error: .InvalidDeviceInput)
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
        
        captureSession.startRunning()
    }
}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {  // キャプチャしたメタデータを出力し、生成されたデータを受信するメソッド
    /*
     func metadataOutput(_:didOutput:from:) : 新しいメタデータが出力された時に、デリゲートに通知するメソッド
     ## 宣言
     ```
     optional func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                             from connection: AVCaptureConnection)
     ```
     ## パラメータ
     - captureOutput
     [AVCaptureMetadataOutput(指定されたメタデータを検出し、その処理のためにデリゲートに転送する)](https://developer.apple.com/documentation/avfoundation/avcapturemetadataoutput)をキャプチャー / 発行されたメタデータ
     - metadataObjects
     [AVMetadataObject(常に新しい配列)](https://developer.apple.com/documentation/avfoundation/avmetadataobject)に放出されたメタデータ。
     - connection
     キャプチャ接続が放出されたオブジェクト
     
     */
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first else {  // (配列の中で)最新のメタデータを取得
            //scannerDelegate?.didSurface(error: .invalidScannedValue)
            return
        }
        
        // AVMetadataMachineReadableCodeObject : メタデータキャプチャ出力によって検出されたバーコード情報
        guard let machineReadableObject = object as? AVMetadataMachineReadableCodeObject else {
            //scannerDelegate?.didSurface(error: .invalidScannedValue)
            return
        }
        
        // stringValue : 文字型の数字列
        guard let barcode = machineReadableObject.`stringValue` else {
            //scannerDelegate?.didSurface(error: .invalidScannedValue)
            return
        }
        
        scannerDelegate?.didFind(barcode: barcode)  // didFindメソッドを動かすよbarcode引数に変数barcodeを代入するよ
    }
}
