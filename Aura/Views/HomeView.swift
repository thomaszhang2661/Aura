import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // soft purple background
                Color(red: 236/255, green: 229/255, blue: 245/255)
                    .ignoresSafeArea()

                VStack(spacing: 28) {
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                        Spacer()
                        Text("Aura")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "person.crop.circle")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    Spacer()

                    VStack(spacing: 28) {
                        NavigationLink(destination: MoodLog()) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 221/255, green: 210/255, blue: 233/255))
                                .frame(height: 140)
                                .overlay(
                                    Text("Log Your\nMood")
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 34, weight: .bold, design: .rounded))
                                        .foregroundColor(.black)
                                )
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black.opacity(0.7), lineWidth: 3))
                        }

                        Button(action: {}) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 221/255, green: 210/255, blue: 233/255))
                                .frame(height: 140)
                                .overlay(
                                    Text("Chat\nwith Aura")
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundColor(.black)
                                )
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black.opacity(0.7), lineWidth: 3))
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    HomeView()
}
