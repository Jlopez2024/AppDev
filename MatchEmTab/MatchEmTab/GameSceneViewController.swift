//
//  ViewController.swift
//  MatchEmTab
//
//  Created by Guest User on 10/21/24.
//
//  Future Goals: Remove redundancies in some of the functions and fix minor edge case
//  errors. Maybe move some of the programatic ui elements to storyboard for improved 
//  consistency.

import UIKit

class GameSceneViewController: UIViewController, ConfigSceneDelegate {

    var configVC: ConfigSceneViewController?
    
    var rectangles: [UIButton] = []
    var firstSelectedRectangle: UIButton?
    var startGameButton: UIButton!
    var restartGameButton: UIButton!
    
    var totalPairsLabel: UILabel!
    var matchesMadeLabel: UILabel!
    var timerLabel: UILabel!
    
    var totalPairs: Int = 0
    var matchesMade: Int = 0
    var timer: Timer?
    public var timeRemaining: Int = 6
    private var initialTimeLimit: Int = 6
    public var gameSpeed: Double = 1.0
    var highScore: Int = 0
    @IBOutlet weak var highScoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let cvc = tabBarController?.viewControllers![1] as? ConfigSceneViewController {
            configVC = cvc
            configVC?.delegate = self  // Set the delegate
        }
        designHighScoreButton()
        highScoreLabel.isHidden = true
        createStartGameButton()
        createCounters()
        createTimerLabel()
    }

    func didUpdateTimeLimit(_ timeLimit: Int) {
        timeRemaining = timeLimit
        initialTimeLimit = timeLimit
        resetTimer()
        timerLabel.text = "Time: \(timeRemaining)" // Update the timer label
        print("Time limit updated in GameSceneViewController: \(timeRemaining)")  // Debug statement

    }
    
    func didUpdateSpeed(_ speed: Double) {
        gameSpeed = 1 / speed
        print("Speed updated to \(gameSpeed)")
    }
    
    func didChangeColor(_ color: UIColor) {
        view.backgroundColor = color
    }
    
    func didResetScore() {
        highScore = 0
    }
    
    func designHighScoreButton() {
        highScoreLabel.layer.cornerRadius = 25
        highScoreLabel.layer.masksToBounds = true // Used to fix the cornerRadius not applying to the label. Thank you stack overflow.
        highScoreLabel.backgroundColor = .white
        highScoreLabel.frame.size = CGSize(width: 150, height: 50)
        highScoreLabel.frame = CGRect(x: 100, y: 300, width: 200, height: 60)
    }

    // MARK: - Create Counters
    func createCounters() {
        totalPairsLabel = UILabel(frame: CGRect(x: 20, y: 50, width: 200, height: 40))
        totalPairsLabel.text = "Amount of pairs: 0"
        totalPairsLabel.textColor = .black
        totalPairsLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(totalPairsLabel)
        
        matchesMadeLabel = UILabel(frame: CGRect(x: 250, y: 50, width: 200, height: 40))
        matchesMadeLabel.text = "Matches made: 0"
        matchesMadeLabel.textColor = .black
        matchesMadeLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(matchesMadeLabel)
    }
    
    // MARK: - Create Timer Label
    func createTimerLabel() {
        timerLabel = UILabel(frame: CGRect(x: 165, y: 90, width: 100, height: 40))
        timerLabel.text = "Time: \(timeRemaining)"
        timerLabel.textColor = .black
        timerLabel.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(timerLabel)
    }
    
    

    // MARK: - Create Start Game Button
    func createStartGameButton() {
        startGameButton = UIButton(type: .system)
        startGameButton.setTitle("Start Game", for: .normal)
        startGameButton.setTitleColor(.white, for: .normal)
        startGameButton.backgroundColor = .blue
        startGameButton.layer.cornerRadius = 10 // Rounds out the corners. Thought it looked nice.
        startGameButton.frame.size = CGSize(width: 150, height: 50)
        
        // Position the button in the center of the screen
        startGameButton.center = view.center
        
        // Add an action to start the game
        startGameButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        
        view.addSubview(startGameButton)
    }
    
    var isGameActive: Bool = false
    
    @objc func startGame() {
        print("Start game was called")
        print("game speed: \(gameSpeed)")
        guard !isGameActive else { return } // Prevent starting a new game if one already active
        isGameActive = true
        
        startGameButton.isHidden = true
        matchesMade = 0
        matchesMadeLabel.text = "Matches made: 0"
        
        resetTimer()
        startTimer()

        createPairsAtVariableRate()
    }
    var pairsCreationTimer: Timer?

    func createPairsAtVariableRate() {
        // Invalidate any existing timer before creating a new one
        pairsCreationTimer?.invalidate()
        
        pairsCreationTimer = Timer.scheduledTimer(withTimeInterval: gameSpeed, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            // Only create pairs if time is remaining
            if self.timeRemaining > 0 {
                self.createPair()
            } else {
                timer.invalidate()  // Stop creating pairs when time runs out
            }
        }
    }
    
    func createPair() {
        let randomColor = getRandomColor()
        let randomSize = getRandomSize()

        createRectangle(color: randomColor, size: randomSize)
        createRectangle(color: randomColor, size: randomSize)
    }
    

    // MARK: - Start Timer with Time Limit
    func startTimer() {
        timerLabel.text = "Time: \(timeRemaining)" // Update the label
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timeRemaining -= 1
            self?.timerLabel.text = "Time: \(self?.timeRemaining ?? 0)"
            
            if self?.timeRemaining == 0 {
                self?.timer?.invalidate()
                self?.endGame()
            }
        }
    }
    
    func resetTimer() {
        timer?.invalidate()  // Stop any previous timer
        timeRemaining = initialTimeLimit
        timerLabel.text = "Time: \(timeRemaining)"
    }

    // MARK: - End Game Logic
    func endGame() {
        print("End game was called")

        highScoreLabel.isHidden = false
        if matchesMade > highScore {
            highScore = matchesMade
            highScoreLabel.text = "High Score: \(highScore)"
            highScoreLabel.textColor = .systemYellow
        } else {
            highScoreLabel.textColor = .black
        }
        
        if rectangles.isEmpty {
            // Create new pairs if all other pairs are matched
            startGame()
        } else {
            // If time runs out, delete remaining rectangles and show the restart button
            
            for rectangle in rectangles {
                rectangle.removeFromSuperview()
            }
            rectangles.removeAll()
            isGameActive = false
            createRestartGameButton()
        }
    }

    // MARK: - Restart Game
    @objc func restartGame() {
        print("Restart game is being called")
        highScoreLabel.isHidden = true
        // Remove all remaining rectangles from the view and reset the game
            for rectangle in rectangles {
                rectangle.removeFromSuperview()
            }
            rectangles.removeAll()
            if let restartButton = restartGameButton {
                restartButton.isHidden = true
            } else {
                print("restartGameButton is nil.")
            }
            startGame()
    }

    // MARK: - Create Restart Game Button
    func createRestartGameButton() {
        // Button formatting
        restartGameButton = UIButton(type: .system)
        restartGameButton.setTitle("Restart Game", for: .normal)
        restartGameButton.setTitleColor(.white, for: .normal)
        restartGameButton.backgroundColor = .red
        restartGameButton.layer.cornerRadius = 10
        restartGameButton.frame.size = CGSize(width: 150, height: 50)
        restartGameButton.center = view.center
        
        // Add an action to restart the game
        restartGameButton.addTarget(self, action: #selector(restartGame), for: .touchUpInside)
        
        // Add the button to the view (initially hidden)
        restartGameButton.isHidden = false
        view.addSubview(restartGameButton)
    }
    
    

    // MARK: - Create Pairs of Rectangles with Random Colors and Sizes
    func createPairs(numberOfPairs: Int) {
        for _ in 0..<numberOfPairs {
            let randomColor = getRandomColor()
            let randomSize = getRandomSize()

            createRectangle(color: randomColor, size: randomSize)
            createRectangle(color: randomColor, size: randomSize)
        }
    }

    func createRectangle(color: UIColor, size: CGSize) {
        let rectangle = UIButton()
        rectangle.backgroundColor = color
        rectangle.frame.size = size
        rectangle.layer.cornerRadius = 8
        rectangle.addTarget(self, action: #selector(handleRectangleClick(sender:)), for: .touchUpInside)
        
        // Keep rectangles from overlapping boundaries of the view
        let minY: CGFloat = 150
        let maxX = view.frame.width - size.width
        
        // Adjust maxY to account for the tab bar height
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        let maxY = view.frame.height - size.height - tabBarHeight

        let randomX = CGFloat.random(in: 0...maxX)
        let randomY = CGFloat.random(in: minY...maxY)

        rectangle.frame.origin = CGPoint(x: randomX, y: randomY)
        
        view.addSubview(rectangle)
        rectangles.append(rectangle)
    }


    // MARK: - Get Random Color
    func getRandomColor() -> UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }

    // MARK: - Get Random Size with Constraints
    func getRandomSize() -> CGSize {
        let randomWidth = CGFloat.random(in: 50...150)
        let randomHeight = CGFloat.random(in: 30...100)
        return CGSize(width: randomWidth, height: randomHeight)
    }

    // MARK: - Handle Rectangle Click
    @objc func handleRectangleClick(sender: UIButton) {
        if let firstRectangle = firstSelectedRectangle {
            // This is the second rectangle being clicked
            if sender.backgroundColor == firstRectangle.backgroundColor && sender != firstRectangle {
                // It's a match
                highlightRectangle(sender)
                removePair(firstRectangle, secondRectangle: sender)
            } else {
                // Not a match, remove highlight from the first rectangle
                resetHighlight(firstRectangle)
                
                // Highlight the current (second) rectangle and make it the first selection
                highlightRectangle(sender)
                firstSelectedRectangle = sender
            }
        } else {
            // First rectangle clicked, highlight it
            highlightRectangle(sender)
            firstSelectedRectangle = sender
        }
        
        // Check if the game has ended (no more rectangles)
        checkForGameEnd()
    }

    // CHANGE the border color of a rectangle
    func highlightRectangle(_ rectangle: UIButton) {
        rectangle.layer.borderWidth = 3
        rectangle.layer.borderColor = UIColor.yellow.cgColor  // Highlight with yellow border
    }

    // Remove the border color from a rectangle
    func resetHighlight(_ rectangle: UIButton) {
        rectangle.layer.borderWidth = 0
    }


    func removePair(_ firstRectangle: UIButton, secondRectangle: UIButton) {
        firstRectangle.removeFromSuperview()
        secondRectangle.removeFromSuperview()
        
        // Remove from the rectangles array
        if let firstIndex = rectangles.firstIndex(of: firstRectangle) {
            rectangles.remove(at: firstIndex)
        }
        if let secondIndex = rectangles.firstIndex(of: secondRectangle) {
            rectangles.remove(at: secondIndex)
        }
        
        firstSelectedRectangle = nil  // Clear the selection
        matchesMade += 1
        matchesMadeLabel.text = "Matches made: \(matchesMade)"
    }
    
    func resetGameView() {
        isGameActive = false
        
        // Remove all rectangles
        for rectangle in rectangles {
            rectangle.removeFromSuperview()
        }
        rectangles.removeAll()

        // Hide or reset any labels or counters if needed
        matchesMade = 0
        matchesMadeLabel.text = "Matches made: 0"
        totalPairsLabel.text = "Amount of pairs: 0"
        timerLabel.text = "Time: \(timeRemaining)"
        
        // Show the Start Game button
        startGameButton.isHidden = false

        // Invalidate and reset the timer
        timer?.invalidate()
        timer = nil
        timeRemaining = 6
    }


    // MARK: - Check if the game has ended
    func checkForGameEnd() {
        if rectangles.isEmpty {
            // Game has ended, reset for a new game or show restart button
            endGame()
        }
    }
    
    var isReturningFromSettings = false

    
    override func viewWillAppear(_ animated: Bool) {
        if !isGameActive {
            resetGameView()
        }
    }
    
    func resetGame() {
        // Reset all game variables without starting a new game
        isGameActive = false
        rectangles.removeAll()
        matchesMade = 0
        matchesMadeLabel.text = "Matches made: 0"
        totalPairsLabel.text = "Amount of pairs: 0"
        timerLabel.text = "Time: \(timeRemaining)"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetGame()
        isReturningFromSettings = true
        isGameActive = false // Reset the game state

    }

    
    
    
}

