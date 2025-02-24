//
//  MusicGeneration.swift
//  EmoAntidote
//
//  Created by 林菁阳 on 2025/2/14.
//

import Foundation

func createTrack(promptText: String, completion: @escaping (String?) -> Void) {
    let url = URL(string: "https://public-api.beatoven.ai/api/v1/tracks")!
    var request = URLRequest(url: url)
    
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer qIN5iSz0CrGcFi0Ic8pGH3k9_iq6BSpC", forHTTPHeaderField: "Authorization")
    
    // Define the payload
    let body: [String: Any] = [
        "prompt": [
            "text": promptText
        ]
    ]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
    } catch {
        print("Error encoding body: \(error)")
        completion(nil)
        return
    }
    
    // Make the network request
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error making request: \(error)")
            completion(nil)
            return
        }
        
        guard let data = data else {
            print("No data returned")
            completion(nil)
            return
        }
        
        // Parse the JSON response
        do {
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let tracks = jsonResponse["tracks"] as? [String],
               let trackId = tracks.first {
                completion(trackId)
            } else {
                print("Error parsing response: \(data)")
                completion(nil)
            }
        } catch {
            print("Error decoding response: \(error)")
            completion(nil)
        }
    }
    
    task.resume()
}

