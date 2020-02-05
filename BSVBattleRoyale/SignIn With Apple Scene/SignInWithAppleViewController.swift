//
//  SignInWithAppleViewController.swift
//  BSVBattleRoyale
//
//  Created by joshua kaunert on 2/5/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import UIKit
import AuthenticationServices

class SignInWithAppleViewController: UIViewController {

    // MARK: - UI Actions

    @objc func signInButtonPressed() {

        // First you create an apple id provider request with the scope of full name and email
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        // Instanstiate and configure the authorization controller
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.presentationContextProvider = self
        authorizationController.delegate = self

        // Perform the request
        authorizationController.performRequests()
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppleIDButton()
    }

    // MARK: - View Setup

    func setupAppleIDButton() {

        // Instantiate the button with a type and style
        let signInButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)

        // Add an action to be called when tapping the button
        signInButton.addTarget(self, action: #selector(signInButtonPressed), for: .touchUpInside)

        // Add button to view and setup constraints
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signInButton)
        NSLayoutConstraint.activate([
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signInButton.widthAnchor.constraint(equalToConstant: 250),
            signInButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Presentations

    func presentCouldNotAuthenticateAlert() {
        // Present alert
    }

    // MARK: - Networking

    func exchangeCode(_ code: String, handler: (String?, Error?) -> Void) {
        // Call your backend to exchange an API token with the code.
    }
}

extension SignInWithAppleViewController: ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

extension SignInWithAppleViewController: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let authError = ASAuthorizationError(_nsError: error as NSError)
        switch authError.code {
        case .canceled:
            break
        default:
            presentCouldNotAuthenticateAlert()
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            if let data = credential.authorizationCode, let code = String(data: data, encoding: .utf8) {
                // Now send the 'code' to your backend to get an API token.
                exchangeCode(code) { apiToken, error in
                    // Handle response
                }
            } else {
                // Handle missing authorization code ...
            }
        }
    }
}

