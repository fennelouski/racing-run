//
//  AuthenticationManager.swift
//  Racing Run
//
//  Manages user authentication state
//

import Foundation
import Combine

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()

    @Published var currentUser: User?
    @Published var isAuthenticated = false

    private let userDefaultsKey = "currentUser"

    private init() {
        loadSavedUser()
    }

    private func loadSavedUser() {
        if let userData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
            isAuthenticated = true
        }
    }

    private func saveUser(_ user: User) {
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: userDefaultsKey)
        }
        currentUser = user
        isAuthenticated = true
    }

    func register(email: String, username: String, password: String) async throws {
        let response = try await APIClient.shared.register(email: email, username: username, password: password)
        await MainActor.run {
            saveUser(response.user)
        }
    }

    func login(email: String, password: String) async throws {
        let response = try await APIClient.shared.login(email: email, password: password)
        await MainActor.run {
            saveUser(response.user)
        }
    }

    func logout() {
        APIClient.shared.logout()
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        currentUser = nil
        isAuthenticated = false
    }
}
