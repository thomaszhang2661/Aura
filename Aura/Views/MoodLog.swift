import SwiftUI

struct MoodLog: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIndex: Int? = nil
    @State private var journal: String = ""

    private let moods: [(label: String, emoji: String)] = [
        ("Happy", "🙂"),
        ("Okay", "😐"),
        ("Anxious", "😧"),
        ("Sad", "☹️")
    ]

    var body: some View {
        ZStack {
            Color(red: 252/255, green: 249/255, blue: 247/255)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 12) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.black)
                    }

                    Text("Mood Logging")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.black)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Mood buttons
                HStack(spacing: 24) {
                    ForEach(Array(moods.enumerated()), id: \.
0) { index, mood in
                        VStack(spacing: 8) {
                            Button(action: { selectedIndex = index }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 249/255, green: 239/255, blue: 224/255))
                                        .frame(width: 72, height: 72)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedIndex == index ? Color.purple : Color.black.opacity(0.6), lineWidth: selectedIndex == index ? 4 : 2)
                                        )

                                    Text(mood.emoji)
                                        .font(.system(size: 30))
                                }
                            }

                            Text(mood.label)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.horizontal)

                // Journal entry
                VStack(alignment: .leading, spacing: 8) {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.8), lineWidth: 3)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                            .frame(height: 180)

                        TextEditor(text: $journal)
                            .padding(12)
                            .frame(height: 180)
                            .background(Color.clear)

                        if journal.isEmpty {
                            Text("Journal entry (optional)")
                                .foregroundColor(.gray)
                                .padding(18)
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    MoodLog()
}
