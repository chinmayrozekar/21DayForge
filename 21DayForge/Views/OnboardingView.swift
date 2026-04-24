import SwiftUI

struct OnboardingView: View {
    
    @Binding var hasCompletedOnboarding: Bool
    @Binding var userName: String
    @FocusState private var isNameFocused: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.orange)
                
                Text("Hi! What should we call you?")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            TextField("Your name", text: $userName)
                .textFieldStyle(.roundedBorder)
                .font(.title3)
                .textContentType(.name)
                .focused($isNameFocused)
                .submitLabel(.done)
                .onSubmit {
                    if !userName.trimmingCharacters(in: .whitespaces).isEmpty {
                        hasCompletedOnboarding = true
                    }
                }
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            isNameFocused = true
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false), userName: .constant(""))
}