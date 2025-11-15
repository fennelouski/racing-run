//
//  GameViewController.swift
//  Racing Run
//
//  Created by Nathan Fennel on 10/8/25.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    private let leaderboardButton = UIButton(type: .system)
    private var currentScore: Int = 0
    private var currentDistance: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLeaderboardButton()

        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill

                // Present the scene
                view.presentScene(scene)
            }

            view.ignoresSiblingOrder = true

            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    private func setupLeaderboardButton() {
        leaderboardButton.setTitle("🏆 Leaderboard", for: .normal)
        leaderboardButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        leaderboardButton.backgroundColor = .systemBlue.withAlphaComponent(0.8)
        leaderboardButton.setTitleColor(.white, for: .normal)
        leaderboardButton.layer.cornerRadius = 20
        leaderboardButton.translatesAutoresizingMaskIntoConstraints = false
        leaderboardButton.addTarget(self, action: #selector(showLeaderboard), for: .touchUpInside)
        view.addSubview(leaderboardButton)

        NSLayoutConstraint.activate([
            leaderboardButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            leaderboardButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            leaderboardButton.widthAnchor.constraint(equalToConstant: 150),
            leaderboardButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    @objc private func showLeaderboard() {
        let leaderboardVC = LeaderboardViewController()
        let navController = UINavigationController(rootViewController: leaderboardVC)
        present(navController, animated: true)
    }

    // Call this method when the game ends to submit score
    func submitScore(score: Int, distance: Int) {
        currentScore = score
        currentDistance = distance

        // Only submit if authenticated
        guard AuthenticationManager.shared.isAuthenticated else {
            return
        }

        let characterId = CharacterImageManager.shared.getCurrentCharacterId()

        Task {
            do {
                let result = try await APIClient.shared.submitScore(
                    characterId: characterId,
                    score: score,
                    distance: distance
                )

                await MainActor.run {
                    self.showScoreSubmitted(rank: result.rank)
                }
            } catch {
                print("Failed to submit score: \(error)")
            }
        }
    }

    private func showScoreSubmitted(rank: Int) {
        let alert = UIAlertController(
            title: "🎉 Score Submitted!",
            message: "Your rank: #\(rank)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "View Leaderboard", style: .default) { _ in
            self.showLeaderboard()
        })
        alert.addAction(UIAlertAction(title: "Continue", style: .cancel))
        present(alert, animated: true)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
