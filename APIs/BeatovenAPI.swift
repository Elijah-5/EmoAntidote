//
//  BeatovenAPI_2.swift
//  EmoAntidote
//
//  Created by 林菁阳 on 2025/2/15.
//

import Foundation

// Define the API URL and token
let backendV1ApiUrl = "https://public-api.beatoven.ai/api/v1"
let backendApiHeaderKey = "Your API key" // Replace with your actual API key

// Define your track creation data structure
struct TrackMeta: Codable {
    let prompt: Prompt
}

struct Prompt: Codable {
    let text: String
}

// Define the track response structure
struct TrackResponse: Codable {
    var tracks: [String]
}

struct ComposeTrackResponse: Codable {
    let status: String
    let task_id: String
}

struct TrackStatusResponse: Codable {
    let status: String
    let meta: Meta
}

struct Meta: Codable {
    let track_url: String?
}

enum TrackError: Error {
    case invalidUrl
    case connectionError
    case requestError
    case invalidResponse
}

class BeatovenAPI {
    // Create track request
    func createTrack(requestData: TrackMeta) async throws -> TrackResponse {
        let url = URL(string: "\(backendV1ApiUrl)/tracks")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(backendApiHeaderKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = try JSONEncoder().encode(requestData)
        request.httpBody = body
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Debug: Print raw JSON response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw API Response (createTrack): \(jsonString)")  // Log raw response for inspection
        }
        
        let trackResponse = try JSONDecoder().decode(TrackResponse.self, from: data)
        return trackResponse
    }

    
    // Compose track
    func composeTrack(requestData: TrackMeta, trackId: String) async throws -> ComposeTrackResponse {
        let url = URL(string: "\(backendV1ApiUrl)/tracks/compose/\(trackId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(backendApiHeaderKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = try JSONEncoder().encode(requestData)
        request.httpBody = body
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Debug: Print raw JSON response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw API Response (composeTrack): \(jsonString)")  // Log raw response for inspection
        }
        
        let composeResponse = try JSONDecoder().decode(ComposeTrackResponse.self, from: data)
        return composeResponse
    }
    
    // Get track status
    func getTrackStatus(taskId: String) async throws -> TrackStatusResponse {
        let url = URL(string: "\(backendV1ApiUrl)/tasks/\(taskId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(backendApiHeaderKey)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Debug: Print raw JSON response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw API Response (getTrackStatus): \(jsonString)")  // Log raw response for inspection
        }
        
        let trackStatusResponse = try JSONDecoder().decode(TrackStatusResponse.self, from: data)
        return trackStatusResponse
    }
    
    // Download track file
    func downloadTrackFile(from url: String, to path: String) async throws {
        guard let trackUrl = URL(string: url) else {
            throw TrackError.invalidUrl
        }
        
        let (data, _) = try await URLSession.shared.data(from: trackUrl)
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw API Response (download): \(jsonString)")  // Log raw response for inspection
        }
        
        try data.write(to: URL(fileURLWithPath: path))
    }
}
