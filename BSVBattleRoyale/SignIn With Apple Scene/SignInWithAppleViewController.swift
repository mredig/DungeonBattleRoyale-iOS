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
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerLoginButton: UIButton!
    @IBOutlet weak var backgroundStuff: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var signInType: SignInType = .login
       
       enum SignInType {
           case register
           case login
       }
       
    let apiController = APIController()
    
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        print("register button tapped")
        
        if segmentedControl.selectedSegmentIndex == 0 {
            signInType = .register
            registerLoginButton.setTitle("Register", for: .normal)
        } else {
            signInType = .login
            registerLoginButton.setTitle("Login", for: .normal)
        }
    }
    
    

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
        
        switch Int.random(in: 0...10) {
        case 3:
            backgroundStuff.image = UIImage(named: "CowboyBlonde")
            print("cb")
        case 5:
            backgroundStuff.image = UIImage(named: "CowboyRed")
            print("cr")
        case 7:
            backgroundStuff.image = UIImage(named: "DallasCowboys")
            print("DC")
        case 9:
            backgroundStuff.image = UIImage(named: "SchamelessPlug")
            print("shamelessly")
            
        default:
            backgroundStuff.image = UIImage(named: "background")
            print("background")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //performSegue(withIdentifier: "ShowSegueToMainStoryboard", sender: nil)
    }

    // MARK: - View Setup

    func setupAppleIDButton() {

        // Instantiate the button with a type and style
        let signInButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)

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
    
    func registerUser() {
        guard let username = usernameTextField.text,
            let password = passwordTextField.text else { return }
        
        switch signInType {
        case .register:
            print("not using signUp right now")
            apiController.register(with: username, password: password, completion: { (error) in
                if let error = error {
                    NSLog("Error signing up: \(error)")
                } else {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Sign Up Successful", message: "Now please log in.", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true, completion: {
                            self.signInType = .login
                            self.segmentedControl.selectedSegmentIndex = 1
                            self.registerLoginButton.setTitle("Sign In", for: .normal)
                        })
                    }
                }
            })
        case .login:
            //apiController.automatedLoginSuccess()
            navigationController?.popViewController(animated: true)
            
            //            loginController.login(with: username, password: password, completion: { (error) in
            //                if let error = error {
            //                    NSLog("Error logging in: \(error)")
            //                } else {
            //                    DispatchQueue.main.async {
            //                        self.dismiss(animated: true, completion: nil)
            //                    }
            //                }
            //            })
        }
    }

    func exchangeCode(_ code: String, handler: (String?, Error?) -> Void) {
        // Call your backend to exchange an API token with the code.
        print("Auth Code: \(code)")
        performSegue(withIdentifier: "ShowSegueToMainStoryboard", sender: nil)
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

