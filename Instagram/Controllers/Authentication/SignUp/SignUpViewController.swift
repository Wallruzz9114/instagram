//
//  ViewController.swift
//  Instagram
//
//  Created by José Pinto on 3/30/18.
//  Copyright © 2018 Jose Pinto. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Add photo button
    let addPhotoButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        // Add action to pick an image
        button.addTarget(self, action: #selector(bringImagePickerOnAddPhotoButtonPressed), for: .touchUpInside)
        return button
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
        textField.addTarget(self, action: #selector(enableSignUpButtonOnTextInputChange), for: .editingChanged)
        return textField
    }()

    // Username text field
    let usernameTextField: UITextField = {
        let textField: UITextField = UITextField()
        textField.placeholder = "Username"
        textField.autocapitalizationType = .none
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.addTarget(self, action: #selector(enableSignUpButtonOnTextInputChange), for: .editingChanged)
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
        textField.addTarget(self, action: #selector(enableSignUpButtonOnTextInputChange), for: .editingChanged)
        return textField
    }()

    // Confirm Password text field
    let confirmPasswordTextField: UITextField = {
        let textField: UITextField = UITextField()
        textField.placeholder = "Confirm Password"
        textField.autocapitalizationType = .none
        textField.clearButtonMode = .whileEditing
        textField.isSecureTextEntry = true
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.addTarget(self, action: #selector(enableSignUpButtonOnTextInputChange), for: .editingChanged)
        return textField
    }()

    // Sign up button
    let signUpButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = UIColor(hexString: "#95ccf4")
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.setTitleColor(UIColor.white, for: .normal)
        // Set it to disabled by default
        button.isEnabled = false
        // Add action to process signing up when button is pressed
        button.addTarget(self, action: #selector(onSignUpButtonPressed), for: .touchUpInside)
        return button
    }()

    // Sign in button
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)

        let attributedtitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        button.setAttributedTitle(attributedtitle, for: .normal)
        attributedtitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.getInstagramBlue()]))

        button.addTarget(self, action: #selector(onAlreadyHaveAccountButtonPressed), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        // Set up add photo button
        setUpAddPhotoButton()
        // Set up input fields constraints
        setUpInputFields()
        // Set up already have account button
        setUpAlreadyHaveAccountbutton()
    }

    fileprivate func setUpAddPhotoButton() {
        // Add elements into the view as subviews
        view.addSubview(addPhotoButton)

        // Set up add photo button constraints
        addPhotoButton.setConstraintsWithAnchors(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 80, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        addPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    fileprivate func setUpInputFields() {
        // Create a stack view (contains an array of views)
        let inputFieldsStackView: UIStackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, confirmPasswordTextField, signUpButton])

        inputFieldsStackView.distribution = .fillEqually
        inputFieldsStackView.axis = .vertical
        inputFieldsStackView.spacing = 10

        // Add the stack view to the main view
        view.addSubview(inputFieldsStackView)
        // Set up stack view constraints
         inputFieldsStackView.setConstraintsWithAnchors(top: addPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 220)
    }

    fileprivate func setUpAlreadyHaveAccountbutton() {
        // Add elements into the view as subviews
        view.addSubview(alreadyHaveAccountButton)

        // Set up already have account button constraints
        alreadyHaveAccountButton.setConstraintsWithAnchors(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }

    // Handle Signing Up with Firebase: Add a new user
    @objc func onSignUpButtonPressed() {
        // Dismiss Keyboard
        self.view.endEditing(true)
        // Display alert if any text field is empty
        if (usernameTextField.text!.isEmpty || emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty || confirmPasswordTextField.text!.isEmpty) {
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
                // Check if username is already in use
                Database.database().reference().child("users").child("username").queryOrderedByValue().queryEqual(toValue: usernameTextField.text!).observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.exists(){
                            // Username unavailable, choose another one
                            let alert = UIAlertController(title: "USERNAME", message: "is already taken, pick another one", preferredStyle: UIAlertControllerStyle.alert)
                            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                            alert.addAction(ok)
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            // Username available, OK to keep this username
                            // Check the password length: Minimum is 6 characters
                            if self.passwordTextField.text!.count < 6 || self.confirmPasswordTextField.text!.count < 6 {
                                let alert = UIAlertController(title: "PASSWORDS", message: "Must be at least 6 characters long", preferredStyle: UIAlertControllerStyle.alert)
                                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                                alert.addAction(ok)
                                self.present(alert, animated: true, completion: nil)
                            } else {
                                // If password are different, alert the user
                                if self.passwordTextField.text != self.confirmPasswordTextField.text {
                                    let alert = UIAlertController(title: "PASSWORDS", message: "Do not match", preferredStyle: UIAlertControllerStyle.alert)
                                    let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                                    alert.addAction(ok)
                                    self.present(alert, animated: true, completion: nil)
                                } else {
                                    guard let email = self.emailTextField.text else { return }
                                    guard let username = self.usernameTextField.text else { return }
                                    guard let password = self.passwordTextField.text else { return }

                                    Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                                        if let error = error {
                                            print("Error while creating a user: ", error.localizedDescription)
                                            return
                                        } else {
                                            print("User successfully created!", user?.uid ?? "")

                                            // Save profile picture to Firebase
                                            guard let profileImage = self.addPhotoButton.imageView?.image else { return }
                                            guard let uploadData = UIImageJPEGRepresentation(profileImage, 0.3) else { return }
                                            let fileName = NSUUID().uuidString

                                            Storage.storage().reference().child("profile_pictures").child(fileName).putData(uploadData, metadata: nil, completion: { (metadata, error) in
                                                if let error = error {
                                                    print("Failed to upload profile picture:", error.localizedDescription)
                                                    return
                                                } else {
                                                    print("Profile picture successfully uploaded!")

                                                    guard let profileImageURL = metadata?.downloadURL()?.absoluteString else { return }
                                                    // Save other info to Firebase
                                                    guard let uid = user?.uid else { return }
                                                    let userValues = ["email": email, "username": username, "profile_picture_url": profileImageURL]
                                                    let values = [uid: userValues]

                                                    Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (error, reference) in
                                                        if let error = error {
                                                            print("Failed to save user into database:", error.localizedDescription)
                                                            return
                                                        } else {
                                                            print("New user saved successfully into Firebase!")
                                                            // Reset view controllers and dismiss SignUpViewController
                                                            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
                                                            mainTabBarController.setUpViewControllers()
                                                            self.dismiss(animated: true, completion: nil)
                                                        }
                                                    })
                                                }
                                            })
                                        }
                                    }
                                }
                            }
                        }
                    }
                )
            }
        }
    }

    // Only enable sign up button if all fields are filled
    @objc func enableSignUpButtonOnTextInputChange() {
        let inputTextFieldsNotEmpty = emailTextField.text?.count ?? 0 > 0 && usernameTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0 && confirmPasswordTextField.text?.count ?? 0 > 0

        if inputTextFieldsNotEmpty {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor.getInstagramBlue()
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor(hexString: "#95ccf4")
        }
    }

    // Bring up image selector when Add photo button is pressed
    @objc func bringImagePickerOnAddPhotoButtonPressed() {
        let imagePickerController: UIImagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        // Allow editing of picked image (zoom in/out etc.)
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }

    // If sign in button is pressed, redirect to login screen
    @objc func onAlreadyHaveAccountButtonPressed() {
        // Redirect to previous view controller (Sign in page)
        navigationController?.popViewController(animated: true)
    }

    // Get the image the user picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            addPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            addPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }

        // round the corners
        addPhotoButton.layer.cornerRadius = addPhotoButton.frame.width / 2
        addPhotoButton.layer.masksToBounds = true
        // Highlight borders
        addPhotoButton.layer.borderColor = UIColor.magenta.cgColor
        addPhotoButton.layer.borderWidth = 3

        // Allow for dismissal after editing
        dismiss(animated: true, completion: nil)
    }

    func isEmailValid(email: String?) -> Bool {
        guard email != nil else { return false }
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)

        return pred.evaluate(with: email)
    }

}

