//
//  SessionManager.swift
//  Instagram Clone
//
//  Created by Sweety on 11/07/2023.
//

import Foundation
import FirebaseAuth

class SessionManager {
    static let shared = SessionManager()
    
    private var currentIGUser: InstagramUser?
    
    var isUserLogin: Bool {
        return currentIGUser != nil
    }
    
    func getUser() -> InstagramUser? {
        return currentIGUser
    }
    
    func signIn(withEmail email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let authResult = authResult, error == nil else {
                completion(error)
                return
            }
            
            APICaller.shared.fetchUser(withUserUID: authResult.user.uid) { [weak self] result in
                switch result {
                case .success(let user):
                    self?.currentIGUser = user
                    completion(nil)
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(error)
                }
            }
            
        }
    }
    
    
    
    func signUp(withEmail email: String,
                password: String,
                username: String,
                profileImage: UIImage,
                completion: @escaping (Error?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                completion(error)
                return
            }
            
            //=================== update profile name =================================
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges { error in
                if let error = error {
                    print(error)
                    return
                }
                
                // ================= add user to database ===========================
                let jsonUser: [String: Any] = [
                    "uid": user.uid,
                    "name": user.displayName!,
                    "email": user.email!,
                    "profilePic": profileImage
                ]
                
                APICaller.shared.createUser(with: jsonUser) { error in
                    
                    guard error == nil else {
                        completion(error)
                        return
                    }
                    completion(nil)

                }
                
            }
            //==========================================================================
        }
    }
    
    func SignOut() {
        do {
            try Auth.auth().signOut()
            currentIGUser = nil
        } catch {
            print("error when signout")
        }
    }
    
    func checkIsLogin(completion: @escaping (Bool) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("user did not login yet from ValidateUser()")
            completion(false)
            return
        }
        
        APICaller.shared.fetchUser(withUserUID: userUID) { [weak self] result in
            switch result {
            case .success(let user):
                self?.currentIGUser = user
                completion(true)
            case .failure(let error):
                print(error.localizedDescription)
                completion(false)
            }
        }
    }
    
    
    
    

    
    
}
