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
    private let currentCharacterIdKey = "currentCharacterId"

    // In-memory cache
    private var charactersCache: [Character] = []
    private var imageCache: [String: UIImage] = [:]

    private init() {}

    // MARK: - Local Storage (Legacy - for offline use)

    /// Save the character's face image locally
    func saveCharacterFace(_ image: UIImage) {
        // Convert image to PNG data
        if let imageData = image.pngData() {
            userDefaults.set(imageData, forKey: faceImageKey)
            userDefaults.synchronize()
        }
    }

    /// Load the saved character face image from local storage
    func loadCharacterFace() -> UIImage? {
        guard let imageData = userDefaults.data(forKey: faceImageKey) else {
            return nil
        }
        return UIImage(data: imageData)
    }

    /// Check if a character face has been saved locally
    func hasCharacterFace() -> Bool {
        return userDefaults.data(forKey: faceImageKey) != nil
    }

    /// Delete the saved character face from local storage
    func deleteCharacterFace() {
        userDefaults.removeObject(forKey: faceImageKey)
        userDefaults.synchronize()
    }

    // MARK: - Cloud Storage

    /// Create a new character in the cloud
    func createCloudCharacter(name: String, image: UIImage) async throws -> Character {
        let character = try await APIClient.shared.createCharacter(name: name, image: image)

        // Save locally as well for offline access
        saveCharacterFace(image)

        // Update cache
        charactersCache.append(character)
        imageCache[character.id] = image

        // Set as current character
        setCurrentCharacterId(character.id)

        return character
    }

    /// Fetch all characters from cloud
    func fetchCloudCharacters() async throws -> [Character] {
        let characters = try await APIClient.shared.getCharacters()
        charactersCache = characters
        return characters
    }

    /// Delete a character from cloud
    func deleteCloudCharacter(_ characterId: String) async throws {
        try await APIClient.shared.deleteCharacter(id: characterId)

        // Remove from cache
        charactersCache.removeAll { $0.id == characterId }
        imageCache.removeValue(forKey: characterId)

        // Clear current if it was deleted
        if getCurrentCharacterId() == characterId {
            clearCurrentCharacterId()
        }
    }

    /// Load character image from URL with caching
    func loadCharacterImage(from urlString: String) async throws -> UIImage {
        // Check cache first
        if let cached = imageCache[urlString] {
            return cached
        }

        // Download image
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: 0)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw NSError(domain: "Invalid image data", code: 0)
        }

        // Cache it
        imageCache[urlString] = image

        return image
    }

    // MARK: - Current Character Management

    func setCurrentCharacterId(_ id: String) {
        userDefaults.set(id, forKey: currentCharacterIdKey)
    }

    func getCurrentCharacterId() -> String? {
        return userDefaults.string(forKey: currentCharacterIdKey)
    }

    func clearCurrentCharacterId() {
        userDefaults.removeObject(forKey: currentCharacterIdKey)
    }

    func getCurrentCharacter() -> Character? {
        guard let currentId = getCurrentCharacterId() else {
            return nil
        }
        return charactersCache.first { $0.id == currentId }
    }

    // MARK: - Cache Management

    func clearCache() {
        charactersCache.removeAll()
        imageCache.removeAll()
    }
}
