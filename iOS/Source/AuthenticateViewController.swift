//
//  AuthenticateViewController.swift
//  Dome
//
//  Created by Ивлев Александр on 06/07/2019.
//  Copyright © 2019 SIA. All rights reserved.
//


import UIKit
import AVFoundation

class AuthenticateViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate
{

    internal var finishHandler: ((_ qrCodeValue: String) -> Void)?

    internal var storage: Storage?
    internal var network: Network?

    private let captureSession: AVCaptureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    private var qrCodeFrameView: UIView?
    private var qrCodeOkButton: UIButton?

    private var lastFoundString: String?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureQRCodeViews()
        self.initializeScanner()
        // Do any additional setup after loading the view.
    }

    private func configureQRCodeViews()
    {
        let qrCodeFrameView = UIView(frame: .zero)
        self.qrCodeFrameView = qrCodeFrameView

        qrCodeFrameView.isHidden = true

        qrCodeFrameView.layer.cornerRadius = 30
        qrCodeFrameView.layer.borderColor = UIColor.green.withAlphaComponent(0.5).cgColor
        qrCodeFrameView.layer.borderWidth = 8

        self.view.addSubview(qrCodeFrameView)

        let qrCodeOkButton = UIButton(frame: .zero)
        self.qrCodeOkButton = qrCodeOkButton

        qrCodeOkButton.setTitle("Принять", for: .normal)
        qrCodeOkButton.setTitleColor(UIColor.green, for: .normal)
        qrCodeOkButton.titleLabel?.font = UIFont.systemFont(ofSize: 25.0, weight: .medium)
        qrCodeOkButton.titleLabel?.layer.shadowColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        qrCodeOkButton.titleLabel?.layer.shadowOffset = .zero
        qrCodeOkButton.titleLabel?.layer.shadowRadius = 5.0

        qrCodeOkButton.addTarget(self, action: #selector(clickOk), for: .touchDown)
        qrCodeOkButton.sizeToFit()

        qrCodeFrameView.addSubview(qrCodeOkButton)
    }

    private func initializeScanner() {

        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get the camera device")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)

            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)

            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]

        } catch {
            fatalError("Can't start scan qr code: \(error)")
        }

        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
        self.videoPreviewLayer = videoPreviewLayer

        captureSession.startRunning()
    }

    @objc
    private func clickOk() {
        if let string = self.lastFoundString {
            finishHandler?(string)
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        qrCodeFrameView?.isHidden = true

        guard let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
            return
        }

        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            if let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj) {
                if let qrCodeFrameView = self.qrCodeFrameView {
                    qrCodeFrameView.frame = barCodeObject.bounds.insetBy(dx: -10, dy: -10)
                    let size = qrCodeFrameView.frame.size
                    qrCodeOkButton?.center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
                    qrCodeFrameView.isHidden = false

                    view.bringSubviewToFront(qrCodeFrameView)
                }
            }

            if let string = metadataObj.stringValue {
                self.lastFoundString = string
            }
        }
    }

}



