//
//  LoginViewController.swift
//  Racing Run
//
//  Authentication view controller
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let emailTextField = UITextField()
    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let registerButton = UIButton(type: .system)
    private let switchModeButton = UIButton(type: .system)
    private let skipButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private var isLoginMode = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Title
        titleLabel.text = "🏃‍♂️ Racing Run"
        titleLabel.font = .systemFont(ofSize: 36, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Email TextField
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emailTextField)

        // Username TextField (for registration)
        usernameTextField.placeholder = "Username"
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.autocapitalizationType = .none
        usernameTextField.isHidden = true
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameTextField)

        // Password TextField
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passwordTextField)

        // Login Button
        loginButton.setTitle("Login", for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 25
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        view.addSubview(loginButton)

        // Register Button
        registerButton.setTitle("Register", for: .normal)
        registerButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        registerButton.backgroundColor = .systemGreen
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 25
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.isHidden = true
        registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        view.addSubview(registerButton)

        // Switch Mode Button
        switchModeButton.setTitle("Need an account? Register", for: .normal)
        switchModeButton.translatesAutoresizingMaskIntoConstraints = false
        switchModeButton.addTarget(self, action: #selector(toggleMode), for: .touchUpInside)
        view.addSubview(switchModeButton)

        // Skip Button (for offline mode)
        skipButton.setTitle("Skip - Play Offline", for: .normal)
        skipButton.setTitleColor(.systemGray, for: .normal)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.addTarget(self, action: #selector(skipLogin), for: .touchUpInside)
        view.addSubview(skipButton)

        // Activity Indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        // Constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),

            usernameTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            usernameTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            usernameTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),

            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),

            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 200),
            loginButton.heightAnchor.constraint(equalToConstant: 50),

            registerButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerButton.widthAnchor.constraint(equalToConstant: 200),
            registerButton.heightAnchor.constraint(equalToConstant: 50),

            switchModeButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            switchModeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc private func toggleMode() {
        isLoginMode.toggle()

        UIView.animate(withDuration: 0.3) {
            if self.isLoginMode {
                self.usernameTextField.isHidden = true
                self.loginButton.isHidden = false
                self.registerButton.isHidden = true
                self.switchModeButton.setTitle("Need an account? Register", for: .normal)
            } else {
                self.usernameTextField.isHidden = false
                self.loginButton.isHidden = true
                self.registerButton.isHidden = false
                self.switchModeButton.setTitle("Have an account? Login", for: .normal)
            }
        }
    }

    @objc private func handleLogin() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }

        activityIndicator.startAnimating()
        loginButton.isEnabled = false

        Task {
            do {
                try await AuthenticationManager.shared.login(email: email, password: password)
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.loginButton.isEnabled = true
                    self.navigateToCharacterCreation()
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.loginButton.isEnabled = true
                    self.showAlert(title: "Login Failed", message: error.localizedDescription)
                }
            }
        }
    }

    @objc private func handleRegister() {
        guard let email = emailTextField.text, !email.isEmpty,
              let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }

        activityIndicator.startAnimating()
        registerButton.isEnabled = false

        Task {
            do {
                try await AuthenticationManager.shared.register(email: email, username: username, password: password)
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.registerButton.isEnabled = true
                    self.navigateToCharacterCreation()
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.registerButton.isEnabled = true
                    self.showAlert(title: "Registration Failed", message: error.localizedDescription)
                }
            }
        }
    }

    @objc private func skipLogin() {
        navigateToCharacterCreation()
    }

    private func navigateToCharacterCreation() {
        let characterCreationVC = CharacterCreationViewController()
        characterCreationVC.modalPresentationStyle = .fullScreen
        present(characterCreationVC, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
