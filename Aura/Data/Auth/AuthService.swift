//
//  AuthService.swift
//  Aura
//
//  Created by Stephen Wang on 11/18/25.
//

import Foundation
import FirebaseAuth

final class AuthService {

    static let shared = AuthService()
    private init() {}

    // current user uid (for other modules)
    var currentUserUID: String? {
        Auth.auth().currentUser?.uid
    }

    // sign up
    func signUp(email: String,
                password: String,
                completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                print("❌ Firebase signUp error")
                print("   code: \(error.code)")
                print("   domain: \(error.domain)")
                print("   userInfo: \(error.userInfo)")
                completion(.failure(error))
                return
            }

            guard let fbUser = result?.user else {
                completion(.failure(AuthError.noUser))
                return
            }

            let user = User(uid: fbUser.uid, email: fbUser.email ?? email)
            completion(.success(user))
        }
    }

    // sign in
    func signIn(email: String,
                password: String,
                completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let fbUser = result?.user else {
                completion(.failure(AuthError.noUser))
                return
            }
            let user = User(uid: fbUser.uid, email: fbUser.email ?? email)
            completion(.success(user))
        }
    }

    // sign out
    func signOut() -> Result<Void, Error> {
        do {
            try Auth.auth().signOut()
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    enum AuthError: LocalizedError {
        case noUser

        var errorDescription: String? {
            switch self {
            case .noUser:
                return "No user returned from Firebase."
            }
        }
    }
}
