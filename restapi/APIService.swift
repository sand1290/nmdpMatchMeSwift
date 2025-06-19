//
//  APIService.swift
//  nmdpMatchMeSwiftUI
//
//  Created by Steven Anderson on 2025-06-16.
//

import Foundation

class APIService {
    var baseUrl = URL(string: "https://mdm8v.wiremockapi.cloud")
    
    func fetchHlaResults(from pathSuffix: String, completion: @escaping (HlaResult?) -> Void) {
        guard let url = baseUrl else {
            completion(nil)
            return
        }

        let fullUrl = url.appendingPathComponent(pathSuffix)
        
        let task = URLSession.shared.dataTask(with: fullUrl) { data, response, error in
            // Check for errors
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
                completion(nil)
                return
            }

            // Check for valid response and data
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Invalid response or data")
                completion(nil)
                return
            }

            // Decode the JSON data
            do {
                let hlaResult = try JSONDecoder().decode(HlaResult.self, from: data)
                completion(hlaResult)
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }

        task.resume()
    }
}
