//
//  Models.swift
//  Racing Run
//
//  API response models
//

import Foundation

// MARK: - User Models

struct User: Codable {
    let id: String
    let email: String
    let username: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, email, username
        case createdAt = "created_at"
    }
}

struct AuthResponse: Codable {
    let user: User
    let token: String
}

// MARK: - Character Models

struct Character: Codable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let imageUrl: String
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name
        case userId = "user_id"
        case imageUrl = "image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct CharacterResponse: Codable {
    let character: Character
}

struct CharactersResponse: Codable {
    let characters: [Character]
}

// MARK: - Score Models

struct Score: Codable, Identifiable {
    let id: String
    let score: Int
    let distance: Int
    let gameMode: String
    let createdAt: Date?
    let characterName: String?
    let characterImage: String?

    enum CodingKeys: String, CodingKey {
        case id, score, distance
        case gameMode = "game_mode"
        case createdAt = "created_at"
        case characterName = "character_name"
        case characterImage = "character_image"
    }
}

struct ScoreSubmissionResponse: Codable {
    let score: Score
    let rank: Int
}

struct ScoresResponse: Codable {
    let scores: [Score]
}

// MARK: - Leaderboard Models

struct LeaderboardEntry: Codable, Identifiable {
    let id: String
    let score: Int
    let distance: Int
    let gameMode: String
    let createdAt: Date?
    let userId: String
    let username: String
    let characterId: String?
    let characterName: String?
    let characterImage: String?

    enum CodingKeys: String, CodingKey {
        case id, score, distance, username
        case gameMode = "game_mode"
        case createdAt = "created_at"
        case userId = "user_id"
        case characterId = "character_id"
        case characterName = "character_name"
        case characterImage = "character_image"
    }
}

struct LeaderboardResponse: Codable {
    let leaderboard: [LeaderboardEntry]
    let limit: Int
    let offset: Int
    let gameMode: String
}

// MARK: - Content Models

struct ContentItem: Codable, Identifiable {
    let id: String
    let type: String
    let name: String
    let description: String?
    let dataUrl: String
    let isPremium: Bool
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, type, name, description
        case dataUrl = "data_url"
        case isPremium = "is_premium"
        case createdAt = "created_at"
    }
}

struct ContentResponse: Codable {
    let content: [ContentItem]
}

// MARK: - Challenge Models

struct DailyChallenge: Codable {
    let type: String
    let name: String
    let description: String
    let target: Int
    let reward: String
    let date: String
    let expiresAt: String
}

struct DailyChallengeResponse: Codable {
    let challenge: DailyChallenge
}

// MARK: - Moderation Models

struct ModerationResult: Codable {
    let approved: Bool
    let message: String?
    let reason: String?
}
