//
//  APIClient.swift
//  Racing Run
//
//  API client for backend communication
//

import Foundation
import UIKit

class APIClient {
    static let shared = APIClient()

    // Configure this with your Vercel deployment URL
    private let baseURL = ProcessInfo.processInfo.environment["API_BASE_URL"] ?? "http://localhost:3000"

    private var authToken: String? {
        get { UserDefaults.standard.string(forKey: "authToken") }
        set { UserDefaults.standard.set(newValue, forKey: "authToken") }
    }

    private init() {}

    // MARK: - Request Methods

    private func makeRequest(
        endpoint: String,
        method: String,
        body: [String: Any]? = nil,
        requiresAuth: Bool = false
    ) async throws -> Data {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth, let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        return data
    }

    private func uploadMultipart(
        endpoint: String,
        method: String = "POST",
        fields: [String: String],
        imageData: Data?,
        imageName: String = "image",
        requiresAuth: Bool = false
    ) async throws -> Data {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        if requiresAuth, let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        var body = Data()

        // Add text fields
        for (key, value) in fields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // Add image
        if let imageData = imageData {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(imageName)\"; filename=\"image.png\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        return data
    }

    // MARK: - Authentication

    func register(email: String, username: String, password: String) async throws -> AuthResponse {
        let body: [String: Any] = [
            "email": email,
            "username": username,
            "password": password
        ]

        let data = try await makeRequest(endpoint: "/api/auth/register", method: "POST", body: body)
        let response = try JSONDecoder().decode(AuthResponse.self, from: data)
        authToken = response.token
        return response
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]

        let data = try await makeRequest(endpoint: "/api/auth/login", method: "POST", body: body)
        let response = try JSONDecoder().decode(AuthResponse.self, from: data)
        authToken = response.token
        return response
    }

    func logout() {
        authToken = nil
    }

    func isAuthenticated() -> Bool {
        return authToken != nil
    }

    // MARK: - Characters

    func getCharacters() async throws -> [Character] {
        let data = try await makeRequest(endpoint: "/api/characters", method: "GET", requiresAuth: true)
        let response = try JSONDecoder().decode(CharactersResponse.self, from: data)
        return response.characters
    }

    func createCharacter(name: String, image: UIImage) async throws -> Character {
        guard let imageData = image.pngData() else {
            throw APIError.invalidImage
        }

        let data = try await uploadMultipart(
            endpoint: "/api/characters",
            fields: ["name": name],
            imageData: imageData,
            requiresAuth: true
        )

        let response = try JSONDecoder().decode(CharacterResponse.self, from: data)
        return response.character
    }

    func deleteCharacter(id: String) async throws {
        _ = try await makeRequest(endpoint: "/api/characters/\(id)", method: "DELETE", requiresAuth: true)
    }

    // MARK: - Scores

    func submitScore(characterId: String?, score: Int, distance: Int, gameMode: String = "endless") async throws -> ScoreSubmissionResponse {
        var body: [String: Any] = [
            "score": score,
            "distance": distance,
            "gameMode": gameMode
        ]

        if let characterId = characterId {
            body["characterId"] = characterId
        }

        let data = try await makeRequest(endpoint: "/api/scores", method: "POST", body: body, requiresAuth: true)
        return try JSONDecoder().decode(ScoreSubmissionResponse.self, from: data)
    }

    func getMyScores(limit: Int = 20) async throws -> [Score] {
        let data = try await makeRequest(endpoint: "/api/scores?limit=\(limit)", method: "GET", requiresAuth: true)
        let response = try JSONDecoder().decode(ScoresResponse.self, from: data)
        return response.scores
    }

    // MARK: - Leaderboard

    func getLeaderboard(limit: Int = 10, offset: Int = 0, gameMode: String = "endless") async throws -> [LeaderboardEntry] {
        let data = try await makeRequest(
            endpoint: "/api/leaderboard?limit=\(limit)&offset=\(offset)&gameMode=\(gameMode)",
            method: "GET"
        )
        let response = try JSONDecoder().decode(LeaderboardResponse.self, from: data)
        return response.leaderboard
    }

    // MARK: - Content

    func getContent(type: String? = nil) async throws -> [ContentItem] {
        var endpoint = "/api/content"
        if let type = type {
            endpoint += "?type=\(type)"
        }

        let data = try await makeRequest(endpoint: endpoint, method: "GET")
        let response = try JSONDecoder().decode(ContentResponse.self, from: data)
        return response.content
    }

    func getDailyChallenge() async throws -> DailyChallenge {
        let data = try await makeRequest(endpoint: "/api/content/daily-challenge", method: "GET")
        let response = try JSONDecoder().decode(DailyChallengeResponse.self, from: data)
        return response.challenge
    }

    // MARK: - Face Processing

    func processFace(image: UIImage) async throws -> UIImage {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw APIError.invalidImage
        }

        let data = try await uploadMultipart(
            endpoint: "/api/face/process",
            fields: [:],
            imageData: imageData
        )

        guard let processedImage = UIImage(data: data) else {
            throw APIError.invalidImage
        }

        return processedImage
    }

    func moderateImage(image: UIImage) async throws -> ModerationResult {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw APIError.invalidImage
        }

        let data = try await uploadMultipart(
            endpoint: "/api/face/moderate",
            fields: [:],
            imageData: imageData
        )

        return try JSONDecoder().decode(ModerationResult.self, from: data)
    }
}

// MARK: - Error Types

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidImage
    case httpError(statusCode: Int, data: Data)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidImage:
            return "Invalid image data"
        case .httpError(let statusCode, let data):
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = json["error"] as? String {
                return "Error \(statusCode): \(message)"
            }
            return "HTTP Error: \(statusCode)"
        }
    }
}
