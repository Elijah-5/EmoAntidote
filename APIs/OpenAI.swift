import Foundation

// Define the model response structure based on the OpenAI API response format
struct OpenAIResponse: Codable {
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let role: String
        let content: String
    }
    
    let choices: [Choice]?
}

class OpenAIAPI {
    
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions" // Corrected endpoint for GPT-4
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func generateText(prompt: String, model: String = "gpt-4", maxTokens: Int = 250, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "OpenAIAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // Create the request body for chat-based models
        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": "You are a helpful assistant."],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": maxTokens
        ]
        
        // Convert to JSON data
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            completion(.failure(NSError(domain: "OpenAIAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize JSON"])))
            return
        }
        
        // Create the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Make the network request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Parse the response data
            guard let data = data else {
                completion(.failure(NSError(domain: "OpenAIAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            // Log raw response data for debugging
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response: \(rawResponse)")
            }
            
            do {
                // Decode JSON response using Codable
                let decoder = JSONDecoder()
                let openAIResponse = try decoder.decode(OpenAIResponse.self, from: data)
                
                // Check if the 'choices' key exists and has values
                if let choices = openAIResponse.choices, let message = choices.first?.message {
                    completion(.success(message.content))
                } else {
                    completion(.failure(NSError(domain: "OpenAIAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "No 'choices' key or message found in response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
