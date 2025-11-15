//
//  LeaderboardViewController.swift
//  Racing Run
//
//  Displays global leaderboard
//

import UIKit

class LeaderboardViewController: UIViewController {

    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var leaderboardEntries: [LeaderboardEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadLeaderboard()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "🏆 Leaderboard"

        // Table View
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LeaderboardCell.self, forCellReuseIdentifier: "LeaderboardCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // Activity Indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        // Close Button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(close)
        )

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func loadLeaderboard() {
        activityIndicator.startAnimating()

        Task {
            do {
                let entries = try await APIClient.shared.getLeaderboard(limit: 50)
                await MainActor.run {
                    self.leaderboardEntries = entries
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showError(error.localizedDescription)
                }
            }
        }
    }

    @objc private func close() {
        dismiss(animated: true)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Table View Delegate & Data Source

extension LeaderboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboardEntries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath) as! LeaderboardCell
        let entry = leaderboardEntries[indexPath.row]
        let rank = indexPath.row + 1
        cell.configure(with: entry, rank: rank)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - Leaderboard Cell

class LeaderboardCell: UITableViewCell {

    private let rankLabel = UILabel()
    private let usernameLabel = UILabel()
    private let scoreLabel = UILabel()
    private let characterImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Rank Label
        rankLabel.font = .systemFont(ofSize: 24, weight: .bold)
        rankLabel.textColor = .systemGray
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rankLabel)

        // Character Image
        characterImageView.contentMode = .scaleAspectFill
        characterImageView.layer.cornerRadius = 25
        characterImageView.clipsToBounds = true
        characterImageView.backgroundColor = .systemGray5
        characterImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(characterImageView)

        // Username Label
        usernameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(usernameLabel)

        // Score Label
        scoreLabel.font = .systemFont(ofSize: 16, weight: .regular)
        scoreLabel.textColor = .systemGray
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(scoreLabel)

        NSLayoutConstraint.activate([
            rankLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            rankLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 40),

            characterImageView.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 10),
            characterImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            characterImageView.widthAnchor.constraint(equalToConstant: 50),
            characterImageView.heightAnchor.constraint(equalToConstant: 50),

            usernameLabel.leadingAnchor.constraint(equalTo: characterImageView.trailingAnchor, constant: 15),
            usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),

            scoreLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            scoreLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 5),
        ])
    }

    func configure(with entry: LeaderboardEntry, rank: Int) {
        rankLabel.text = "#\(rank)"
        usernameLabel.text = entry.username

        // Format score with commas
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let scoreText = formatter.string(from: NSNumber(value: entry.score)) ?? "\(entry.score)"
        scoreLabel.text = "\(scoreText) points • \(entry.distance)m"

        // Medal for top 3
        if rank == 1 {
            rankLabel.text = "🥇"
        } else if rank == 2 {
            rankLabel.text = "🥈"
        } else if rank == 3 {
            rankLabel.text = "🥉"
        }

        // Load character image if available
        if let imageUrl = entry.characterImage {
            loadImage(from: imageUrl)
        } else {
            characterImageView.image = nil
        }
    }

    private func loadImage(from urlString: String) {
        Task {
            do {
                let image = try await CharacterImageManager.shared.loadCharacterImage(from: urlString)
                await MainActor.run {
                    self.characterImageView.image = image
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
    }
}
