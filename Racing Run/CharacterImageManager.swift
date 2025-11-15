//
//  CharacterImageManager.swift
//  Racing Run
//
//  Created by Nathan Fennel on 10/8/25.
//

import UIKit

class CharacterImageManager {
    static let shared = CharacterImageManager()

    private let userDefaults = UserDefaults.standard
    private let faceImageKey = "characterFaceImage"

    private init() {}

    /// Save the character's face image
    func saveCharacterFace(_ image: UIImage) {
        // Convert image to PNG data
        if let imageData = image.pngData() {
            userDefaults.set(imageData, forKey: faceImageKey)
            userDefaults.synchronize()
        }
    }

    /// Load the saved character face image
    func loadCharacterFace() -> UIImage? {
        guard let imageData = userDefaults.data(forKey: faceImageKey) else {
            return nil
        }
        return UIImage(data: imageData)
    }

    /// Check if a character face has been saved
    func hasCharacterFace() -> Bool {
        return userDefaults.data(forKey: faceImageKey) != nil
    }

    /// Delete the saved character face
    func deleteCharacterFace() {
        userDefaults.removeObject(forKey: faceImageKey)
        userDefaults.synchronize()
    }
}
