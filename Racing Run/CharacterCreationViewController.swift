//
//  CharacterCreationViewController.swift
//  Racing Run
//
//  Created by Nathan Fennel on 10/8/25.
//

import UIKit
import AVFoundation
import Vision

class CharacterCreationViewController: UIViewController {

    // MARK: - UI Components
    private let cameraView = UIView()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let captureButton = UIButton(type: .system)
    private let instructionLabel = UILabel()
    private let retakeButton = UIButton(type: .system)
    private let continueButton = UIButton(type: .system)
    private let previewImageView = UIImageView()

    // MARK: - Camera Components
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var capturedImage: UIImage?
    private var processedFaceImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkCameraPermissions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = cameraView.bounds
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Camera view
        cameraView.backgroundColor = .black
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraView)

        // Instruction label
        instructionLabel.text = "Take a picture of your face!"
        instructionLabel.font = .systemFont(ofSize: 24, weight: .bold)
        instructionLabel.textColor = .white
        instructionLabel.textAlignment = .center
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)

        // Capture button
        captureButton.setTitle("📸 Take Photo", for: .normal)
        captureButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        captureButton.backgroundColor = .systemBlue
        captureButton.setTitleColor(.white, for: .normal)
        captureButton.layer.cornerRadius = 25
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        view.addSubview(captureButton)

        // Preview image view (hidden initially)
        previewImageView.contentMode = .scaleAspectFit
        previewImageView.backgroundColor = .black
        previewImageView.isHidden = true
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewImageView)

        // Retake button (hidden initially)
        retakeButton.setTitle("🔄 Retake", for: .normal)
        retakeButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        retakeButton.backgroundColor = .systemOrange
        retakeButton.setTitleColor(.white, for: .normal)
        retakeButton.layer.cornerRadius = 25
        retakeButton.translatesAutoresizingMaskIntoConstraints = false
        retakeButton.isHidden = true
        retakeButton.addTarget(self, action: #selector(retakePhoto), for: .touchUpInside)
        view.addSubview(retakeButton)

        // Continue button (hidden initially)
        continueButton.setTitle("✓ Use This Photo", for: .normal)
        continueButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        continueButton.backgroundColor = .systemGreen
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 25
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.isHidden = true
        continueButton.addTarget(self, action: #selector(continueToGame), for: .touchUpInside)
        view.addSubview(continueButton)

        // Constraints
        NSLayoutConstraint.activate([
            // Camera view - takes up most of the screen
            cameraView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cameraView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),

            // Instruction label
            instructionLabel.bottomAnchor.constraint(equalTo: cameraView.topAnchor, constant: -10),
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Capture button
            captureButton.topAnchor.constraint(equalTo: cameraView.bottomAnchor, constant: 30),
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.widthAnchor.constraint(equalToConstant: 200),
            captureButton.heightAnchor.constraint(equalToConstant: 50),

            // Preview image view (same position as camera view)
            previewImageView.topAnchor.constraint(equalTo: cameraView.topAnchor),
            previewImageView.leadingAnchor.constraint(equalTo: cameraView.leadingAnchor),
            previewImageView.trailingAnchor.constraint(equalTo: cameraView.trailingAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: cameraView.bottomAnchor),

            // Retake button
            retakeButton.topAnchor.constraint(equalTo: cameraView.bottomAnchor, constant: 30),
            retakeButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10),
            retakeButton.widthAnchor.constraint(equalToConstant: 150),
            retakeButton.heightAnchor.constraint(equalToConstant: 50),

            // Continue button
            continueButton.topAnchor.constraint(equalTo: cameraView.bottomAnchor, constant: 30),
            continueButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            continueButton.widthAnchor.constraint(equalToConstant: 150),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Camera Permissions
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert()
        @unknown default:
            break
        }
    }

    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Access Needed",
            message: "Please enable camera access in Settings to take your photo!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Camera Setup
    private func setupCamera() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            print("Failed to setup camera")
            return
        }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        captureSession.commitConfiguration()

        // Setup preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = cameraView.bounds
        cameraView.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer

        // Start the session on a background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    // MARK: - Photo Capture
    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    @objc private func retakePhoto() {
        capturedImage = nil
        processedFaceImage = nil
        previewImageView.isHidden = true
        cameraView.isHidden = false
        captureButton.isHidden = false
        retakeButton.isHidden = true
        continueButton.isHidden = true
        instructionLabel.text = "Take a picture of your face!"

        // Restart camera session
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    @objc private func continueToGame() {
        // Save the processed face image
        if let image = processedFaceImage {
            CharacterImageManager.shared.saveCharacterFace(image)
        }

        // Navigate to game
        let gameVC = GameViewController()
        gameVC.modalPresentationStyle = .fullScreen
        present(gameVC, animated: true)
    }

    // MARK: - Face Detection and Processing
    private func processFaceImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }

        let request = VNDetectFaceRectanglesRequest { [weak self] request, error in
            guard let self = self,
                  let results = request.results as? [VNFaceObservation],
                  let face = results.first else {
                self?.showNoFaceDetectedAlert()
                return
            }

            self.extractFace(from: image, faceObservation: face)
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }

    private func extractFace(from image: UIImage, faceObservation: VNFaceObservation) {
        guard let cgImage = image.cgImage else { return }

        // Convert Vision coordinates to image coordinates
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)

        // Add some padding around the face (30% extra on each side)
        let padding: CGFloat = 0.3
        var boundingBox = faceObservation.boundingBox

        boundingBox.origin.x = max(0, boundingBox.origin.x - boundingBox.width * padding)
        boundingBox.origin.y = max(0, boundingBox.origin.y - boundingBox.height * padding)
        boundingBox.size.width = min(1.0 - boundingBox.origin.x, boundingBox.width * (1 + 2 * padding))
        boundingBox.size.height = min(1.0 - boundingBox.origin.y, boundingBox.height * (1 + 2 * padding))

        // Convert to image coordinates (Vision uses bottom-left origin)
        let rect = CGRect(
            x: boundingBox.origin.x * width,
            y: (1 - boundingBox.origin.y - boundingBox.height) * height,
            x: boundingBox.width * width,
            height: boundingBox.height * height
        )

        // Crop the face
        if let croppedCGImage = cgImage.cropping(to: rect) {
            let faceImage = UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)

            DispatchQueue.main.async {
                self.processedFaceImage = faceImage
                self.previewImageView.image = faceImage
                self.instructionLabel.text = "Looking great! Ready to race?"
            }
        }
    }

    private func showNoFaceDetectedAlert() {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "No Face Detected",
                message: "Please make sure your face is clearly visible and try again!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self?.retakePhoto()
            })
            self?.present(alert, animated: true)
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CharacterCreationViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            return
        }

        capturedImage = image

        // Stop the camera session
        captureSession.stopRunning()

        // Show preview
        DispatchQueue.main.async { [weak self] in
            self?.cameraView.isHidden = true
            self?.previewImageView.isHidden = false
            self?.captureButton.isHidden = true
            self?.retakeButton.isHidden = false
            self?.continueButton.isHidden = false
            self?.instructionLabel.text = "Processing your photo..."
        }

        // Process the image to extract face
        processFaceImage(image)
    }
}
