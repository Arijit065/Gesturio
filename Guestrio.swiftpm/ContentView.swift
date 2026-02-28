import SwiftUI

// MARK: - THE ROUTER
struct ContentView: View {
    @State private var isAppStarted: Bool = false
    
    var body: some View {
        Group {
            if isAppStarted {
                MainTranslationView(isAppStarted: $isAppStarted)
                    .transition(.move(edge: .trailing))
            } else {
                HomeView(isAppStarted: $isAppStarted)
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isAppStarted)
    }
}

// MARK: - 1. THE HOME PAGE
struct HomeView: View {
    @Binding var isAppStarted: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.15)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    if let uiImage = UIImage(named: "GesturioIcon") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .cornerRadius(35)
                            .shadow(color: Color.blue.opacity(0.3), radius: 15, x: 0, y: 8)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 35, style: .continuous)
                                .fill(Color.blue)
                                .frame(width: 150, height: 150)
                                .shadow(color: Color.blue.opacity(0.3), radius: 15, x: 0, y: 8)
                            
                            Image(systemName: "hand.wave.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Text("Gesturio")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.blue)
                    
                    Text("Real-time ASL translation at your fingertips.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                Button(action: {
                    isAppStarted = true
                }) {
                    Text("Let's Start")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.blue)
                        .cornerRadius(16)
                        .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - 2. THE MAIN TRANSLATION APP
struct MainTranslationView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Binding var isAppStarted: Bool
    @State private var inputText: String = ""
    
    let columns = [GridItem(.adaptive(minimum: 60, maximum: 90), spacing: 12)]
    
    // LOGIC: Finds the very last valid letter/number typed
    var latestLetter: String? {
        if let last = inputText.last(where: { $0.isLetter || $0.isNumber }) {
            return String(last)
        }
        return nil
    }
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.04)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HeaderView(isIPad: sizeClass == .regular, isAppStarted: $isAppStarted)
                
                SearchBarView(text: $inputText)
                    .padding(.horizontal)
                    .padding(.bottom, 15)
                
                Divider().background(Color.blue.opacity(0.2))
                
                // THE "HERO POP" STAGE
                if !inputText.isEmpty, let activeLetter = latestLetter {
                    VStack(spacing: 8) {
                        Text("Current Sign")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue.opacity(0.5))
                        
                        ASLCard(letter: activeLetter)
                            .frame(width: 130, height: 170)
                            .id(inputText)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background(
                        Color.white
                            .shadow(color: Color.blue.opacity(0.04), radius: 8, y: 4)
                    )
                    .zIndex(1)
                }
                
                // The Grid History
                ScrollView {
                    if inputText.isEmpty {
                        EmptyStateView()
                            .padding(.top, 80)
                    } else {
                        TranslationFlowView(text: inputText, columns: columns)
                    }
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.6), value: inputText)
    }
}

// MARK: - SUB-VIEWS FOR MAIN APP

struct TranslationFlowView: View {
    let text: String
    let columns: [GridItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            let words = text.components(separatedBy: " ")
            
            ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                let cleanWord = String(word.filter { $0.isLetter || $0.isNumber })
                
                if !cleanWord.isEmpty || index == words.count - 1 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Word \(index + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue.opacity(0.7))
                            .padding(.leading, 5)
                        
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                            ForEach(Array(cleanWord.enumerated()), id: \.offset) { _, char in
                                ASLCard(letter: String(char))
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    if index < words.count - 1 && !cleanWord.isEmpty {
                        Divider()
                            .background(Color.blue.opacity(0.1))
                            .padding(.horizontal, 40)
                    }
                }
            }
        }
        .padding(.vertical, 20)
    }
}

struct ASLCard: View {
    let letter: String
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.blue.opacity(0.08), radius: 5, x: 0, y: 3)
                
                if let uiImage = UIImage(named: letter.lowercased()) ?? UIImage(named: "\(letter.lowercased()).jpeg") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(8)
                } else {
                    VStack {
                        Image(systemName: "questionmark.square.dashed")
                            .foregroundColor(.blue.opacity(0.4))
                        Text(letter.uppercased())
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.blue.opacity(0.6))
                    }
                }
            }
            .aspectRatio(0.8, contentMode: .fit)
            
            Text(letter.uppercased())
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.blue.opacity(0.8))
        }
    }
}

struct HeaderView: View {
    let isIPad: Bool
    @Binding var isAppStarted: Bool
    
    var body: some View {
        ZStack {
            // Centered Titles
            VStack(spacing: 4) {
                Text("Gesturio")
                    .font(.system(size: isIPad ? 42 : 32, weight: .heavy, design: .rounded))
                    .foregroundColor(.blue)
                
                Text("Real-time ASL Fingerspelling")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue.opacity(0.7))
            }
            
            // Left Button Only
            HStack {
                Button(action: {
                    isAppStarted = false
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: isIPad ? 35 : 28))
                        .foregroundColor(.blue.opacity(0.6))
                }
                
                Spacer() // Pushes the back button to the left edge
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, isIPad ? 40 : 20)
        .padding(.bottom, 10)
    }
}

struct SearchBarView: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.blue)
            
            TextField("Type a sentence to translate...", text: $text)
                .font(.body)
                .disableAutocorrection(true)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.blue.opacity(0.5))
                }
            }
        }
        .padding(14)
        .background(Color.gray)
        .cornerRadius(15)
        .shadow(color: Color.blue.opacity(0.06), radius: 5, x: 0, y: 2)
        .frame(maxWidth: 700)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "hands.sparkles.fill")
                .font(.system(size: 70))
                .foregroundColor(.blue.opacity(0.2))
            
            Text("Bridge the Gap")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text("Enter text to convert it into\nvisual ASL signs instantly.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundColor(.blue.opacity(0.7))
                .frame(maxWidth: 300)
        }
    }
}
