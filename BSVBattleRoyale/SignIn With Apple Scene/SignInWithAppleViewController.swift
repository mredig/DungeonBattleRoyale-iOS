//
//  SignInWithAppleViewController.swift
//  BSVBattleRoyale
//
//  Created by joshua kaunert on 2/5/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import UIKit
import AuthenticationServices
import NetworkHandler

class SignInWithAppleViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var password1TextField: UITextField!
    @IBOutlet weak var password2TextField: UITextField!
    @IBOutlet weak var registerLoginButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
	@IBOutlet weak var collectionView: UICollectionView!

    var signInType: SignInType = .login
       
       enum SignInType {
           case register
           case login
       }
       
    let apiController = APIController()
	
	var avatars: [AvatarSelectionContainer] = Avatar.allCases.map {
		let container = AvatarSelectionContainer()
		container.avatar = $0
		return container
	}

    
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        print("register button tapped")
        
        if segmentedControl.selectedSegmentIndex == 0 {
            signInType = .register
            registerUser()
        } else {
            signInType = .login
            loginUser()
        }
    }

    
    @IBAction func segmentedControlChanged(_ sender: Any) {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            signInType = .register
            UIView.transition(with: registerLoginButton, duration: 0.3, options: [.transitionCrossDissolve, .curveLinear], animations: {
              self.registerLoginButton.setTitle("Register", for: .normal)
              self.hideViewWithFade(self.password2TextField)
            }, completion: nil)
                        

        } else {
            signInType = .login
            UIView.transition(with: registerLoginButton, duration: 0.4, options: [.transitionCrossDissolve, .curveLinear], animations: {
              self.registerLoginButton.setTitle("Login", for: .normal)
              self.hideViewWithFade(self.password2TextField)
            }, completion: nil)


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
        
//        setupAppleIDButton()


		registerLoginButton.layer.cornerRadius = 8
		registerLoginButton.layer.cornerCurve = .continuous

		avatars.first?.isSelected = true

		collectionView.delegate = self
		collectionView.dataSource = self

		//FIXME: TEST ONLY
//		usernameTextField.text = "ffff"
//		password1TextField.text = "Aabc123!"
//		segmentedControl.selectedSegmentIndex = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    // MARK: - Transitions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let dest = segue.destination as? ViewController {
            dest.apiController = apiController
        }
    }
    
    // smooth fade in/out for views
    func hideViewWithFade(_ view: UIView) {
        if view.isHidden {
            view.alpha = 0.0
        }

        view.isHidden = false

        UIView.animate(withDuration: 0.3, delay: 0.0, options: .transitionCrossDissolve, animations: {
            view.alpha = view.alpha == 1.0 ? 0.0 : 1.0
        }, completion: { _ in
            view.isHidden = !Bool(truncating: view.alpha as NSNumber)
        })
    }

    // MARK: - Networking
    
    func registerUser() {
        guard let username = usernameTextField.text,
            let password = password1TextField.text,
            let password2 = password2TextField.text,
            password2 == password else { return }
        
        apiController.register(with: username, password: password) { (error) in
            if let error = error {
                if let terror = error as? NetworkError {
                    switch terror {
                    case .httpNon200StatusCode(code: _, data: let Data):
                        let string = String(data: Data!, encoding: .utf8)
                        print(string as Any)
                    default:
                        break
                    }
                }
                NSLog("Error registering \(error)")
                return
            }
            if self.apiController.token != nil {
                self.startGame()
            }
        }
    }
    
    
    func startGame() {
		let selectedIndex = avatars.firstIndex(where: { $0.isSelected} ) ?? 0
		let avatar = Avatar(rawValue: selectedIndex) ?? .yellowMonster
		apiController.selectedAvatar = avatar
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "ShowSegueToMainStoryboard", sender: nil)
        }
    }
    
    
    func loginUser() {
        guard let username = usernameTextField.text,
            let password = password1TextField.text else { return }
        
        apiController.login(with: username, password: password) { (error) in
            if let error = error {
                if let terror = error as? NetworkError {
                    switch terror {
                    case .httpNon200StatusCode(code: _, data: let Data):
                        let string = String(data: Data!, encoding: .utf8)!
                        print(string)
                    default:
                        break
                    }
                }
                NSLog("Error logging in user \(error)")
                return
            }
            if self.apiController.token != nil {
                self.startGame()
            }
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

extension SignInWithAppleViewController: UICollectionViewDataSource, UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return avatars.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarCell", for: indexPath)
		guard let avatarCell = cell as? AvatarCollectionViewCell else { return cell }

		let info = avatars[indexPath.item]
		avatarCell.avatar = info
		return avatarCell
	}
}
