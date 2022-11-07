//
//  Firestore.swift
//  ChelsPass
//
//  Created by Shyam Kumar on 11/6/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum FirestoreError: Error {
    case missingSnapshot
    case fetchError(String)
    case setError(String)
    case encodingError
}

extension Firestore {
    static var db: Firestore { Firestore.firestore() }
    
    static func get<T: Codable>(collectionPath: String, type: T.Type, completion: @escaping (Result<[T], FirestoreError>) -> Void) {
        db.collection(collectionPath).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(.fetchError(error.localizedDescription)))
                return
            } else {
                if let snapshot = snapshot {
                    completion(
                        .success(
                            snapshot.documents.compactMap({ dictionaryToCodable(dict: $0.data(), decodeInto: type) })
                        )
                    )
                } else {
                    completion(.failure(.missingSnapshot))
                }
            }
        }
    }
    
    static func get<T: Codable>(documentPath: String, type: T.Type, completion: @escaping (Result<T, FirestoreError>) -> Void) {
        db.document(documentPath).getDocument(as: type) { result in
            switch result {
            case .success(let obj):
                completion(.success(obj))
            case .failure(let error):
                completion(.failure(.fetchError(error.localizedDescription)))
            }
        }
    }
    
    static func `set`<T: Codable>(_ object: T, documentPath: String, completion: @escaping (Result<Bool, FirestoreError>) -> Void) {
        if let dictionary = object.asDictionary() {
            db.document(documentPath).setData(dictionary) { error in
                if let error = error {
                    completion(.failure(.setError(error.localizedDescription)))
                } else {
                    completion(.success(true))
                }
            }
        }
    }
    
    static func update<T: Codable>(_ object: T, documentPath: String, completion: @escaping (Result<Bool, FirestoreError>) -> Void) {
        if let dictionary = object.asDictionary() {
            db.document(documentPath).updateData(dictionary) { error in
                if let error = error {
                    completion(.failure(.setError(error.localizedDescription)))
                } else {
                    completion(.success(true))
                }
            }
        }
    }
    
    // MARK: - Helpers
    static func dictionaryToCodable<T: Codable>(dict: [String: Any], decodeInto: T.Type) -> T? {
        if let data = dictionaryToJSON(dict: dict) {
            do {
                let nativeObj = try JSONDecoder().decode(T.self, from: data)
                return nativeObj
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    private static func dictionaryToJSON(dict: [String: Any]) -> Data? {
        do {
            let data = try JSONSerialization.data(withJSONObject: dict)
            return data
        } catch {
            return nil
        }
    }
}

extension Encodable {
    func asDictionary() -> [String: Any]? {
        if let data = try? JSONEncoder().encode(self),
           let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
            return dictionary
        } else {
            return nil
        }
    }
}
