import Foundation

class TriviaQuestionService {
    
    static func fetchTriviaQuestions(completion: (([TriviaQuestion]) -> Void)? = nil) {
        let urlString = "https://opentdb.com/api.php?amount=10"
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            completion?([])
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard error == nil else {
                print("❌ Network error: \(error!.localizedDescription)")
                completion?([])
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let data = data else {
                print("❌ Invalid response status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                completion?([])
                return
            }

            // 🔎 Print the raw JSON response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📜 Raw API Response: \(jsonString)")
            }

            let decoder = JSONDecoder()
            
            do {
                var response = try decoder.decode(TriviaAPIResponse.self, from: data)

                print("✅ Received \(response.results.count) questions before filtering")
                print("✅ Skipping filtering — using all API results")

                response.results = response.results.map { question in
                    return TriviaQuestion(
                        category: question.category.htmlDecoded,
                        question: question.question.htmlDecoded,
                        correctAnswer: question.correctAnswer.htmlDecoded,
                        incorrectAnswers: question.incorrectAnswers.map { $0.htmlDecoded },
                        type: question.type
                    )
                }
                DispatchQueue.main.async {
                    completion?(response.results)
                }
            } catch {
                print("❌ Decoding error: \(error)")
                completion?([])
            }
        }
        
        task.resume()
    }
}

struct TriviaAPIResponse: Decodable {
    var results: [TriviaQuestion]
}
