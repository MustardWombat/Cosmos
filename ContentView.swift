///
//  ContentView.swift
//  COSMOS
//
//  Created by James Williams on 1/13/25.
//
// MARK: - Imports
import SwiftUI
import Foundation
import Combine
// MARK: - Star System
//System to create "stars" and move them around to simulate being in space.
struct StarOverlay: View {
    @State private var opacity: Double = 1.0 // Animation state
    let starCount: Int // Number of stars

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<starCount, id: \.self) { _ in
                    Circle()
                        .fill(Color.white)
                        .frame(width: CGFloat.random(in: 2...4), height: CGFloat.random(in: 2...4)) // Star size
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .opacity(Double.random(in: 0.5...opacity)) // Random brightness
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 1.0...3.0)).repeatForever(),
                            value: opacity
                        )
                }
            }
            .onAppear {
                withAnimation {
                    opacity = 0.8 // Animate opacity to simulate twinkling
                }
            }
        }
        .ignoresSafeArea()
    }
}
// MARK: - Preview
struct MainView: View {
    @StateObject private var timerModel = StudyTimerModel()
    @StateObject private var currencyModel = CurrencyModel()
    @State private var currentView = "Home"

    var body: some View {
        ZStack {
            // Starry background
            StarOverlay(starCount: 20)

            // Main content
            VStack {
                if currentView == "Home" {
                    HomeView(currentView: $currentView)
                        .environmentObject(timerModel)
                        .environmentObject(currencyModel)
                } else if currentView == "PlanetView" {
                    PlanetView(currentView: $currentView)
                        .environmentObject(timerModel)
                        .environmentObject(currencyModel)
                } else if currentView == "StudySession" {
                    SessionView(currentView: $currentView)
                        .environmentObject(timerModel)
                        .environmentObject(currencyModel)
                } else if currentView == "Help" {
                    ChatHelpView(currentView: $currentView)
                        .environmentObject(timerModel)
                        .environmentObject(currencyModel)
                } else {
                    Text("Unknown View")
                }
            }
        }
        .background(Color.black.ignoresSafeArea()) // Base background color
    }
}
// MARK: - CurrencyModel Class

class CurrencyModel: ObservableObject {
    @Published var balance: Int = 0 // current balance
    func earn(amount: Int){
        balance += amount
    }
}
// MARK: - StudyTimerModel Class
class StudyTimerModel: ObservableObject {
    @Published var earnedRewards: [String] = [] // All earned rewards
    @Published var timeRemaining: Int = 0
    @Published var isTimerRunning: Bool = false
    @Published var totalTimeStudied: Int = 0
    @Published var reward: String? = nil // Current reward
    @Published var gasPoints: Int = 4
    @Published var lastReplenishmentTime: Date? = nil
    @Published var refuelingProgress: Double = 0.0 // Track the refueling progress
    @Published var isRefueling: Bool = false

    private var timer: Timer?
    private var replenishmentTimer: Timer?
    var maxGasPoints = 4

    init() {
        startReplenishmentTimer()
    }

    func startTimer(for duration: Int) {
        guard gasPoints > 0 else { return } // Ensure gas points are available

        if isTimerRunning {
            timeRemaining += duration
        } else {
            timeRemaining = duration
            isTimerRunning = true
            reward = nil

            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.stopTimer()
                    self.calculateReward()
                }
            }
        }

        gasPoints -= 1 // Deduct gas points after adding time
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        calculateReward()
    }

    func calculateReward() {
        // Calculate the reward based on the remaining time
        totalTimeStudied += timeRemaining
        if timeRemaining >= 1800 {
            reward = "🌟 Rare Planet"
        } else if timeRemaining >= 900 {
            reward = "🌕 Common Planet"
        } else {
            reward = "🌑 Tiny Asteroid"
        }

        // Store the earned reward
        if let earnedReward = reward {
            earnedRewards.append(earnedReward)
        }
    }

    // Harvest planets for currency
    func harvestRewards() -> Int {
        let rewardValue = earnedRewards.reduce(0) { total, reward in
            switch reward {
            case "🌟 Rare Planet": return total + 50
            case "🌕 Common Planet": return total + 20
            case "🌑 Tiny Asteroid": return total + 5
            default: return total
            }
        }
        earnedRewards.removeAll() // Clear rewards after harvesting
        return rewardValue
    }

    // Start the gas point replenishment timer
    private func startReplenishmentTimer() {
        replenishmentTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.replenishGasPoints()
        }
    }

    // Replenish gas points
    private func replenishGasPoints() {
        guard gasPoints < maxGasPoints else { return }
        gasPoints += 1
        lastReplenishmentTime = Date()
    }
}


extension Color {
    static let cosmosOrange = Color(hex: "#EF4923") // Replace with your hex color
}

extension Color {
    init(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexSanitized)
        
        // Ensure the hex starts with "#" and skip it
        if hexSanitized.hasPrefix("#") {
            scanner.currentIndex = hexSanitized.index(after: hexSanitized.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue >> 16) & 0xFF) / 255.0
        let green = Double((rgbValue >> 8) & 0xFF) / 255.0
        let blue = Double(rgbValue & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}



// MARK: - Global Navigation Modifier
struct NavigationStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarHidden(true) // Hide the navigation bar globally
            .navigationBarBackButtonHidden(true) // Hide the back button globally
    }
}
// MARK: - ChatGPT API Manager
// Responsible for the operation of the AI assistant the app includes
class ChatGPTAPI: ObservableObject {
    private let apiKey : String
    private let apiUrl = "https://api.openai.com/v1/chat/completions"
    init() {
            guard let key = ProcessInfo.processInfo.environment["OPENAI_API"] else {
                fatalError("API Key not found in environment variables")
            }
            self.apiKey = key
        }
    @Published var messages: [String] = ["Beep Boop! I'm here to help you!"]
    
    func sendMessage(_ userMessage: String) {
        let payload: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant."],
                ["role": "user", "content": userMessage]
            ]
        ]
        
        // Safely create URL
        guard let url = URL(string: apiUrl) else {
            print("Invalid API URL.")
            DispatchQueue.main.async {
                self.messages.append("Error: Unable to connect to the server.")
            }
            return
        }
        
        // Safely serialize JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            print("Failed to create JSON payload.")
            DispatchQueue.main.async {
                self.messages.append("Error: Failed to prepare request data.")
            }
            return
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Perform network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.messages.append("Error: Network issue. Please try again later.")
                }
                return
            }
            
            // Check HTTP response status code
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("Server error: HTTP \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    self.messages.append("Error: Server responded with status \(httpResponse.statusCode).")
                }
                return
            }
            
            // Safely parse response data
            guard let data = data else {
                print("No data received from server.")
                DispatchQueue.main.async {
                    self.messages.append("Error: No response from server.")
                }
                return
            }
            
            do {
                // Decode JSON response
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = jsonResponse["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    DispatchQueue.main.async {
                        self.messages.append(content)
                    }
                } else {
                    print("Invalid JSON structure.")
                    DispatchQueue.main.async {
                        self.messages.append("Error: Unexpected response format.")
                    }
                }
            } catch {
                print("JSON decoding error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.messages.append("Error: Failed to process server response.")
                }
            }
        }.resume()
    }
}
// MARK: - HomeView
// simply displays the home page
    struct HomeView: View {
        @Binding var currentView: String // Proper placement of @Binding
        @State private var path: [String] = [] // Navigation path

        var body: some View {
            NavigationStack(path: $path) {
                VStack {
                    Spacer()
                    
                    VStack {
                        Text("Welcome to COSMOS!")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    PersistentBottomBar(currentView: $currentView)
                }
                .background(Color.cosmosOrange.ignoresSafeArea())

                .navigationBarBackButtonHidden(true)
            }
        }
    }
// MARK: - PlanetView
// simply displays the planet page
struct PlanetView: View {
    @Binding var currentView: String
    @EnvironmentObject var timerModel: StudyTimerModel
    @EnvironmentObject var currencyModel: CurrencyModel

    var body: some View {
        VStack {
            // Display currency balance at the top
            HStack {
                Text("Balance:")
                    .foregroundColor(Color.orange)
                    .font(.headline)
                Text("\(currencyModel.balance) Coins")
                    .foregroundColor(Color.orange)
                    .font(.title)
                    .bold()
            }
            .padding()

            // Title
            Text("Planets:")
                .foregroundColor(Color.orange)
                .font(.largeTitle)
                .bold()
                .padding()

            Spacer()

            // Display Earned Rewards
            EarnedRewardsView()

            Spacer()

            // Harvest Button
            Button(action: {
                // Harvest planets and add currency
                let harvestedCurrency = timerModel.harvestRewards()
                currencyModel.earn(amount: harvestedCurrency)
            }) {
                Text("Harvest Planets")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(timerModel.earnedRewards.isEmpty ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(timerModel.earnedRewards.isEmpty) // Disable if no rewards to harvest

            Spacer()

            // Instructional Text
            Text("Use the study timer to earn planets!")
                .font(.headline)
                .foregroundColor(.white)
                .padding()

            // Persistent Bottom Bar
            PersistentBottomBar(currentView: $currentView)
        }
        .background(Color.black.ignoresSafeArea())
    }
}
// Move EarnedRewardsView Outside PlanetView
struct EarnedRewardsView: View {
    @EnvironmentObject var timerModel: StudyTimerModel

    var body: some View {
        VStack {
            Text("Earned Rewards")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)

            if timerModel.earnedRewards.isEmpty {
                Text("No rewards yet! Start studying to earn planets.")
                    .foregroundColor(.gray)
            } else {
                List {
                    ForEach(timerModel.earnedRewards, id: \.self) { reward in
                        HStack {
                            Text(reward)
                                .font(.title2)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
        .padding()
        .background(
            Color.black.opacity(0.5)
                .cornerRadius(15)
        )
    }
}

// MARK: - StudySessionView
// simply displays the "study" page

struct SessionView: View {
    @Binding var currentView: String

    var body: some View {
        VStack {
            StudyTimerView()
            Spacer()
            PersistentBottomBar(currentView: $currentView)
        }
    }
}

struct StudyTimerView: View {
    @EnvironmentObject var timerModel: StudyTimerModel // Shared timer model
    @State private var elapsedTime: Double = 0.0 // Tracks elapsed time for refueling animation
    @State private var refuelingTimerActive: Bool = false // Prevent multiple timers

    var body: some View {
        VStack(spacing: 20) {
            Text("Focus Timer")
                .font(.largeTitle)
                .bold()

            // Timer Display
            Text(formatTime(timerModel.timeRemaining))
                .font(.system(size: 64, weight: .bold, design: .monospaced))
                .foregroundColor(timerModel.isTimerRunning ? .green : .red)

            if let reward = timerModel.reward {
                Text("You earned: \(reward)")
                    .font(.headline)
                    .foregroundColor(.orange)
            }

            // Gas Points Progress Bar with Refueling Indicator
            VStack {
                Text("Gas")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.bottom, 5)

                ZStack(alignment: .leading) {
                    // Background bar
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 20)

                    // Current gas points
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.green)
                        .frame(width: CGFloat(timerModel.gasPoints) / CGFloat(timerModel.maxGasPoints) * 300, height: 20)

                    // Refueling indicator
                    if timerModel.gasPoints < timerModel.maxGasPoints {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue.opacity(0.4))
                            .frame(width: elapsedTime / 3600.0 * 300, height: 20)
                            .animation(.linear(duration: 1), value: elapsedTime)
                    }
                }
                .frame(width: 300) // Set width for consistent appearance
            }
            .padding()

            Text(refuelingStatus())
                .font(.caption)
                .foregroundColor(.white)

            // Buttons for Timer Control
            HStack {
                Button(action: {
                    // Adds 25 minutes per gas point
                    timerModel.startTimer(for: 25 * 60)
                }) {
                    Text("Add 25 Min")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(timerModel.gasPoints > 0 ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(timerModel.gasPoints == 0) // Disable if no gas points

                Button(action: {
                    timerModel.stopTimer()
                }) {
                    Text("Land")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!timerModel.isTimerRunning) // Disable if timer is not running
            }
            .padding()

            Spacer()
        }
        .padding()
        .onAppear {
            startRefuelingIndicator()
        }
    }

    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func refuelingStatus() -> String {
        if timerModel.gasPoints < timerModel.maxGasPoints {
            let timeLeft = Int(3600 - elapsedTime) // Assuming 1 hour per gas point
            let minutes = timeLeft / 60
            let seconds = timeLeft % 60
            return "Refueling: \(minutes) min \(seconds) sec until next gas point"
        }
        return "Gas tank full!"
    }

    func startRefuelingIndicator() {
        // Prevent multiple timers
        guard !refuelingTimerActive else { return }
        refuelingTimerActive = true

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timerModel.gasPoints >= timerModel.maxGasPoints {
                timer.invalidate() // Stop the timer if gas is full
                refuelingTimerActive = false
            } else {
                elapsedTime += 1
                if elapsedTime >= 3600 { // When 1 hour passes
                    elapsedTime = 0
                    timerModel.gasPoints += 1 // Add a gas point
                }
            }
        }
    }
}


// MARK: - ChatHelpView
// simply displays the ai assistant page
struct ChatHelpView: View {
    @Binding var currentView: String // Proper placement of @Binding
    @State private var message: String = ""
    @ObservedObject var chatGPT = ChatGPTAPI() // ChatGPT API Manager

    var body: some View {
        VStack {
            // Scrollable Chat Messages
            ScrollView {
                ForEach(chatGPT.messages, id: \.self) { msg in
                    HStack {
                        Text(msg)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(msg.starts(with: "You:") ? Color.blue.opacity(0.8) : Color.white.opacity(0.8))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                }
            }
            
            // Input Field and Send Button
            HStack {
                TextField("Type your message...", text: $message)
                    .textFieldStyle(PlainTextFieldStyle()) // Use PlainTextFieldStyle for full control
                    .padding()
                    .background(Color.white) // Background color for the input field
                    .cornerRadius(8) // Rounded corners
                    .frame(height: 44) // Height for the input field
                
                Button(action: {
                    if !message.isEmpty {
                        chatGPT.messages.append("You: \(message)") // Add user's message to chat
                        chatGPT.sendMessage(message) // Send to ChatGPT
                        message = "" // Clear input field
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding()
                        .foregroundColor(.blue) // Icon color
                }
            }
            .padding()

            // Persistent Bottom Bar
            PersistentBottomBar(currentView: $currentView)
        }
        .background(Color.black.ignoresSafeArea()) // Background color for the view
        .navigationBarBackButtonHidden(true) // Hide back button
    }
}

// MARK: - Persistent Bottom Bar
// responsible for controlling the bottom row of buttons
struct PersistentBottomBar: View {
    @Binding var currentView: String // Track the active view

    var body: some View {
        HStack {
            Spacer()

            // Button 1: Home
            Button(action: {
                currentView = "Home"
            }) {
                Image(systemName: "house.fill") // SF Symbol for Home
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding()
                    .background(currentView == "Home" ? Color.gray.opacity(0.2) : Color.white)
                    .foregroundColor(currentView == "Home" ? .gray : .orange)
                    .cornerRadius(8)
            }
            .disabled(currentView == "Home") // Disable if already on Home

            Spacer()

            // Button 2: PlanetView
            Button(action: {
                currentView = "PlanetView"
            }) {
                Image(systemName: "globe") // Placeholder icon
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.orange)
                    .cornerRadius(8)
            }

            Spacer()

            // Button 3: SessionView
            Button(action: {
                currentView = "StudySession"
            }) {
                Image(systemName: "gearshape.fill") // Placeholder icon
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.orange)
                    .cornerRadius(8)
            }
            Spacer()
            // Button 4: Help
            Button(action: {
                currentView = "Help"
            }) {
                Image(systemName: "questionmark.circle.fill") // SF Symbol for Help
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding()
                    .background(currentView == "Help" ? Color.gray.opacity(0.2) : Color.white)
                    .foregroundColor(currentView == "Help" ? .gray : .orange)
                    .cornerRadius(8)
            }
            .disabled(currentView == "Help") // Disable if already on Help
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.2))
    }
}
    #Preview {
        MainView()
    }
