//
//  LoginViewController.swift
//  Instagram
//
//  Created by José Pinto on 4/2/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

    // Logo container
    let logoContainerView: UIView = {
        let view = UIView()
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
        logoImageView.contentMode = .scaleAspectFill

        view.addSubview(logoImageView)
        logoImageView.setConstraintsWithAnchors(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        // #0078af, #bc2a8d, #c32aa3
        view.backgroundColor = UIColor(hexString: "#c32aa3")
        return view
    }()

    // Email text field
    let emailTextField: UITextField = {
        let textField: UITextField = UITextField()
        textField.placeholder = "Email"
        textField.keyboardType = UIKeyboardType.emailAddress
        textField.autocapitalizationType = .none
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.addTarget(self, action: #selector(enableSignInButtonOnTextInputChange), for: .editingChanged)
        return textField
    }()

    // Password text field
    let passwordTextField: UITextField = {
        let textField: UITextField = UITextField()
        textField.placeholder = "Password"
        textField.autocapitalizationType = .none
        textField.clearButtonMode = .whileEditing
        textField.isSecureTextEntry = true
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.addTarget(self, action: #selector(enableSignInButtonOnTextInputChange), for: .editingChanged)
        return textField
    }()

    // Sign in button
    let signInButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = UIColor(hexString: "#95ccf4")
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.setTitleColor(UIColor.white, for: .normal)
        // Set it to disabled by default
        button.isEnabled = false
        // Add action to process signing up when button is pressed
        button.addTarget(self, action: #selector(onSignInButtonPressed), for: .touchUpInside)
        return button
    }()

    // Sign up button
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)

        let attributedtitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        button.setAttributedTitle(attributedtitle, for: .normal)
        attributedtitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.getInstagramBlue()]))

        button.addTarget(self, action: #selector(onSignUpButtonPressed), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true

        view.backgroundColor = UIColor.white
        // Add sub views
        view.addSubview(logoContainerView)
        view.addSubview(signUpButton)

        // Set up sign up button constraints
        signUpButton.setConstraintsWithAnchors(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)

        // Set up logo container with constraints
        logoContainerView.setConstraintsWithAnchors(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 175)

        // Set up input fields and login button
        setUpInputFieldsAndLoginButton()
    }

    // Only enable sign up button if all fields are filled
    @objc func enableSignInButtonOnTextInputChange() {
        let inputTextFieldsNotEmpty = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0

        if inputTextFieldsNotEmpty {
            signInButton.isEnabled = true
            signInButton.backgroundColor = UIColor.getInstagramBlue()   
        } else {
            signInButton.isEnabled = false
            signInButton.backgroundColor = UIColor(hexString: "#95ccf4")
        }
    }

    @objc func onSignUpButtonPressed() {
        // Redirect to Sign up view controller
        let signUpViewController = SignUpViewController()
        navigationController?.pushViewController(signUpViewController, animated: true)
    }

    // Handle loging in with Firebase
    @objc func onSignInButtonPressed() {
        // Dismiss Keyboard
        self.view.endEditing(true)
        // Display alert if any text field is empty
        if (emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty) {
            let alert = UIAlertController(title: "PLEASE", message: "Fill all fields", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        } else {
            // Check if email if valid
            if !isEmailValid(email: emailTextField.text) {
                let alert = UIAlertController(title: "EMAIL", message: "Is not valid. Try again", preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            } else {
                // Check the password length: Minimum is 6 characters
                if passwordTextField.text!.count < 6 {
                    let alert = UIAlertController(title: "PASSWORD", message: "Must be at least 6 characters long", preferredStyle: UIAlertControllerStyle.alert)
                    let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    guard let email = self.emailTextField.text else { return }
                    guard let password = self.passwordTextField.text else { return }

                    Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                        if let error = error {
                            print("Error while loging in: ", error.localizedDescription)
                            return
                        } else {
                            // Successfully logged in
                            print("Successfully logged in with user", user?.uid ?? "")
                            // Reset view controllers and dismiss SignInViewController
                            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
                            mainTabBarController.setUpViewControllers()
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                }
            }
        }
    }

    fileprivate func setUpInputFieldsAndLoginButton() {
        // Create a stack view (contains an array of views)
        let inputFieldsAndButtonStackView: UIStackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, signInButton])

        inputFieldsAndButtonStackView.distribution = .fillEqually
        inputFieldsAndButtonStackView.axis = .vertical
        inputFieldsAndButtonStackView.spacing = 10

        // Add the stack view to the main view
        view.addSubview(inputFieldsAndButtonStackView)
        // Set up stack view constraints
        inputFieldsAndButtonStackView.setConstraintsWithAnchors(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 150)
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    func isEmailValid(email: String?) -> Bool {
        guard email != nil else { return false }
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)

        return pred.evaluate(with: email)
    }

}
