//
//  ViewController.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//

import UIKit

class TriviaViewController: UIViewController {
  
  @IBOutlet weak var currentQuestionNumberLabel: UILabel!
  @IBOutlet weak var questionContainerView: UIView!
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var answerButton0: UIButton!
  @IBOutlet weak var answerButton1: UIButton!
  @IBOutlet weak var answerButton2: UIButton!
  @IBOutlet weak var answerButton3: UIButton!
  
    private var questions = [TriviaQuestion]()
    private var currQuestionIndex = 0
    private var numCorrectQuestions = 0
  
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradient()
        questionContainerView.layer.cornerRadius = 8.0

        TriviaQuestionService.fetchTriviaQuestions { [weak self] fetchedQuestions in
            guard let self = self else { return }

            print("📥 Attempting to store \(fetchedQuestions.count) questions...")

            if fetchedQuestions.isEmpty {
                print("❌ No trivia questions received!")
                return
            }

            self.questions = fetchedQuestions
            self.currQuestionIndex = 0

            print("✅ Stored \(self.questions.count) questions.")

            DispatchQueue.main.async {
                self.updateQuestion(withQuestionIndex: self.currQuestionIndex)
            }
        }
    }

    private func updateQuestion(withQuestionIndex questionIndex: Int) {
        guard !questions.isEmpty, questionIndex < questions.count else {
            print("❌ Error: Trying to update question but no questions available.")
            return
        }

        let question = questions[questionIndex]
        print("🆕 Showing question: \(question.question)")

        questionLabel.text = question.question
        categoryLabel.text = question.category

        let correctAnswer = question.correctAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        var incorrectAnswers = question.incorrectAnswers

        // ✅ Log the actual answers for debugging
        print("🔎 API correct answer: \(question.correctAnswer)")
        print("🔎 API incorrect answers: \(question.incorrectAnswers)")

        // ✅ Ensure `incorrectAnswers` is only replaced if actually empty
        if incorrectAnswers.isEmpty {
            print("⚠️ Warning: No incorrect answers found for this question: \(question.question)")

            if question.type == "boolean" {
                incorrectAnswers = ["True", "False"].filter { $0 != correctAnswer }
            } else {
                incorrectAnswers = [
                    "Wrong Choice 1",
                    "Wrong Choice 2",
                    "Wrong Choice 3"
                ].filter { $0 != correctAnswer }
            }
        }

        print("🔎 Final incorrect answers used: \(incorrectAnswers)")

        let allAnswers = ([correctAnswer] + incorrectAnswers).shuffled()

        let buttons = [answerButton0, answerButton1, answerButton2, answerButton3]

        for button in buttons {
            button?.isHidden = true
        }

        for (index, button) in buttons.prefix(allAnswers.count).enumerated() {
            button?.setTitle(allAnswers[index], for: .normal)
            button?.isHidden = false
        }

        currentQuestionNumberLabel.text = "Question: \(questionIndex + 1)/\(questions.count)"
    }

    private func updateToNextQuestion(answer: String) {
        if isCorrectAnswer(answer) {
            numCorrectQuestions += 1
        }
        currQuestionIndex += 1
        guard currQuestionIndex < questions.count else {
            showFinalScore()
            return
        }
        updateQuestion(withQuestionIndex: currQuestionIndex)
    }

    private func isCorrectAnswer(_ answer: String) -> Bool {
        guard currQuestionIndex >= 0, currQuestionIndex < questions.count else {
            print("Error: currQuestionIndex (\(currQuestionIndex)) is out of range. Questions count: \(questions.count)")
            return false
        }
        return answer == questions[currQuestionIndex].correctAnswer
    }

    private func showFinalScore() {
        let alertController = UIAlertController(title: "Game over!",
                                                message: "Final score: \(numCorrectQuestions)/\(questions.count)",
                                                preferredStyle: .alert)
        let resetAction = UIAlertAction(title: "Restart", style: .default) { [unowned self] _ in
            currQuestionIndex = 0
            numCorrectQuestions = 0
            TriviaQuestionService.fetchTriviaQuestions { [weak self] newQuestions in
                guard let self = self else { return }
                if newQuestions.isEmpty {
                    print("Failed to fetch new questions")
                    return
                }
                self.questions = newQuestions
                DispatchQueue.main.async {
                    self.updateQuestion(withQuestionIndex: 0)
                }
            }
        }
        alertController.addAction(resetAction)
        present(alertController, animated: true, completion: nil)
    }

    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor(red: 0.54, green: 0.88, blue: 0.99, alpha: 1.00).cgColor,
                                UIColor(red: 0.51, green: 0.81, blue: 0.97, alpha: 1.00).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    @IBAction func didTapAnswerButton0(_ sender: UIButton) { handleAnswer(sender) }
        @IBAction func didTapAnswerButton1(_ sender: UIButton) { handleAnswer(sender) }
        @IBAction func didTapAnswerButton2(_ sender: UIButton) { handleAnswer(sender) }
        @IBAction func didTapAnswerButton3(_ sender: UIButton) { handleAnswer(sender) }

        private func handleAnswer(_ sender: UIButton) {
            guard !questions.isEmpty else {
                print("❌ Error: Trying to answer a question when there are no questions loaded!")
                return
            }
            updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
        }
    }
