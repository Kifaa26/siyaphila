import SwiftUI

struct ContentView: View {
    @State private var selectedRole: DemoRole?
    @StateObject private var pitchNavigator = PitchDemoNavigatorState()
    @State private var patientTab = 0
    @State private var clinicianTab = 0
    @State private var medicalAidTab = 0

    var body: some View {
        Group {
            if let selectedRole {
                EcosystemRoleRootView(
                    role: selectedRole,
                    patientTab: $patientTab,
                    clinicianTab: $clinicianTab,
                    medicalAidTab: $medicalAidTab
                ) {
                    self.selectedRole = nil
                }
            } else {
                EcosystemEntryView { role in
                    selectedRole = role
                }
            }
        }
        .overlay {
            PitchDemoController(navigator: pitchNavigator) { step in
                applyPitchStep(step)
            }
        }
        .environmentObject(pitchNavigator)
        .onAppear {
            applyPitchStep(pitchNavigator.currentStep)
            pitchNavigator.requestFocusForCurrentStep()
        }
    }

    private func applyPitchStep(_ step: PitchDemoStep) {
        selectedRole = step.role

        switch step.role {
        case .patient:
            patientTab = step.tab
        case .clinician:
            clinicianTab = step.tab
        case .medicalAid:
            medicalAidTab = step.tab
        }
    }
}

private struct EcosystemEntryView: View {
    let onSelect: (DemoRole) -> Void

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    GradientHeroCard(colors: [Color(hex: "10203B"), Color(hex: "2F55D4"), Color(hex: "7A63FF")]) {
                        VStack(alignment: .leading, spacing: 14) {
                            StatusChip(title: "Chronic medication management", color: .white, icon: "waveform.path.ecg.rectangle")
                            Text("One ecosystem.\nThree connected views.")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Show how clinician prescribing, patient adherence, and medical-aid analytics connect into one AI-powered chronic disease platform.")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.82))
                        }
                    }

                    SectionHeader("Select a role", subtitle: "Each role is a polished demo of how the platform would feel in practice.")

                    VStack(spacing: 16) {
                        ForEach(DemoRole.allCases) { role in
                            Button {
                                onSelect(role)
                            } label: {
                                RoleSelectionCard(role: role)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
            }
            .background(LinearGradient.appBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

private struct EcosystemRoleRootView: View {
    let role: DemoRole
    @Binding var patientTab: Int
    @Binding var clinicianTab: Int
    @Binding var medicalAidTab: Int
    let onExit: () -> Void

    var body: some View {
        switch role {
        case .patient:
            PatientRootView(patient: DemoData.ayo, selectedTab: $patientTab, onExit: onExit)
        case .clinician:
            ClinicianRootView(patient: DemoData.ayo, snapshot: DemoData.clinician, selectedTab: $clinicianTab, onExit: onExit)
        case .medicalAid:
            MedicalAidRootView(patient: DemoData.ayo, analytics: DemoData.analytics, selectedTab: $medicalAidTab, onExit: onExit)
        }
    }
}

private struct RoleSelectionCard: View {
    let role: DemoRole

    private var colors: [Color] {
        switch role {
        case .patient: return [Color(hex: "FF7A59"), Color(hex: "FFB05C"), Color(hex: "FF8E7B")]
        case .clinician: return [Color(hex: "10203B"), Color(hex: "2454C9"), Color(hex: "2F8CFF")]
        case .medicalAid: return [Color(hex: "0F2940"), Color(hex: "1D5266"), Color(hex: "35C98A")]
        }
    }

    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: 58, height: 58)
                Image(systemName: role.icon)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(role.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                Text(role.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 34))
                .foregroundStyle(.white)
        }
        .padding(22)
        .background(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
    }
}

#Preview {
    ContentView()
}
