//
//  NetworkManager.swift
//  Aura
//
//  Created by Member C
//  Network manager for API calls (similar to Alamofire approach from tutorial)
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    // MARK: - Generic GET Request
    func fetchData<T: Decodable>(
        from urlString: String,
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for network error
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            // Check status code
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                
                switch statusCode {
                case 200...299:
                    // Success - parse data
                    guard let data = data else {
                        DispatchQueue.main.async {
                            completion(.failure(NetworkError.noData))
                        }
                        return
                    }
                    
                    do {
                        let decoded = try JSONDecoder().decode(T.self, from: data)
                        DispatchQueue.main.async {
                            completion(.success(decoded))
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                    
                case 400...499:
                    // Client error
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.clientError(statusCode)))
                    }
                    
                default:
                    // Server error
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.serverError(statusCode)))
                    }
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Simple String GET Request (like tutorial's text API)
    func fetchString(
        from urlString: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                
                switch statusCode {
                case 200...299:
                    guard let data = data,
                          let string = String(data: data, encoding: .utf8) else {
                        DispatchQueue.main.async {
                            completion(.failure(NetworkError.noData))
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        completion(.success(string))
                    }
                    
                default:
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.httpError(statusCode)))
                    }
                }
            }
        }
        
        task.resume()
    }
}

// MARK: - Network Errors
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case clientError(Int)
    case serverError(Int)
    case httpError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .clientError(let code):
            return "Client error: \(code)"
        case .serverError(let code):
            return "Server error: \(code)"
        case .httpError(let code):
            return "HTTP error: \(code)"
        }
    }
}
