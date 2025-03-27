//
//  TriviaQuestion.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//
import Foundation

struct TriviaQuestion: Decodable {
    let category: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    let type: String

    private enum CodingKeys: String, CodingKey {
        case category
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
        case type
    }

    // ✅ Custom initializer to allow manual creation
    init(category: String, question: String, correctAnswer: String, incorrectAnswers: [String], type: String) {
        self.category = category
        self.question = question
        self.correctAnswer = correctAnswer
        self.incorrectAnswers = incorrectAnswers
        self.type = type
    }

    // ✅ Decodable initializer to handle missing incorrect answers
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        category = try container.decode(String.self, forKey: .category)
        question = try container.decode(String.self, forKey: .question)
        correctAnswer = try container.decodeIfPresent(String.self, forKey: .correctAnswer) ?? "Unknown"
        incorrectAnswers = try container.decodeIfPresent([String].self, forKey: .incorrectAnswers) ?? ["Incorrect A", "Incorrect B", "Incorrect C"]
        type = try container.decode(String.self, forKey: .type)
    }
}

// ✅ Extension to clean up HTML encoding (e.g., "&quot;" → `"`)
extension String {
    var htmlDecoded: String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let decoded = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else { return self }
        return decoded.string
    }
}
