import SwiftUI
import Combine

struct PitchDemoStep: Identifiable {
    let id: Int
    let icon: String
    let title: String
    let cue: String
    let role: DemoRole
    let tab: Int
    let focusAnchor: String
}

struct PitchFocusRequest: Equatable {
    let anchor: String
    let token: Int
}

@MainActor
final class PitchDemoNavigatorState: ObservableObject {
    @Published var currentStepIndex = 0
    @Published var showSheet = false
    @Published var focusedAnchor: String?
    @Published var focusRequest: PitchFocusRequest?
    private var focusToken = 0

    let steps: [PitchDemoStep] = [
        PitchDemoStep(
            id: 0,
            icon: "person.crop.circle.badge.exclamationmark",
            title: "Ayo: patient risk",
            cue: "Start the demo with Ayo, a patient with diabetes whose missed doses are already lowering adherence and raising complication risk.",
            role: .patient,
            tab: 0,
            focusAnchor: "patientRisk"
        ),
        PitchDemoStep(
            id: 1,
            icon: "pills.fill",
            title: "Medication literacy",
            cue: "Show the medication list and plain-language education: what each drug is for, how to take it, and why stopping matters.",
            role: .patient,
            tab: 2,
            focusAnchor: "medicationLiteracy"
        ),
        PitchDemoStep(
            id: 2,
            icon: "calendar.badge.exclamationmark",
            title: "Adherence slipping",
            cue: "Use the care calendar to make missed doses visible as a pattern instead of an invisible problem after the consultation.",
            role: .patient,
            tab: 4,
            focusAnchor: "adherenceCalendar"
        ),
        PitchDemoStep(
            id: 3,
            icon: "stethoscope",
            title: "Clinician decision support",
            cue: "Jump to the clinician view: poor control may reflect non-adherence, not medication failure, so the treatment decision is better informed.",
            role: .clinician,
            tab: 2,
            focusAnchor: "clinicianDecision"
        ),
        PitchDemoStep(
            id: 4,
            icon: "chart.line.uptrend.xyaxis",
            title: "Medical-aid intelligence",
            cue: "Show how adherence becomes population intelligence: risk queues, avoidable spend, projected savings, and earlier outreach.",
            role: .medicalAid,
            tab: 0,
            focusAnchor: "medicalAidSpend"
        ),
        PitchDemoStep(
            id: 5,
            icon: "brain.head.profile",
            title: "Predictive chronic care",
            cue: "Close with the backend story: diagnosis, medication, adherence, renewal behavior, and outcomes become the dataset for predictive AI.",
            role: .medicalAid,
            tab: 1,
            focusAnchor: "predictiveInputs"
        )
    ]

    var currentStep: PitchDemoStep { steps[currentStepIndex] }
    var canGoBack: Bool { currentStepIndex > 0 }
    var canGoForward: Bool { currentStepIndex < steps.count - 1 }

    func advance(apply: (PitchDemoStep) -> Void) {
        guard canGoForward else { return }
        navigate(to: steps[currentStepIndex + 1], apply: apply)
    }

    func goBack(apply: (PitchDemoStep) -> Void) {
        guard canGoBack else { return }
        navigate(to: steps[currentStepIndex - 1], apply: apply)
    }

    func navigate(to step: PitchDemoStep, apply: (PitchDemoStep) -> Void) {
        currentStepIndex = step.id
        apply(step)
        requestFocus(for: step, delay: 0.45)
    }

    func reset(apply: (PitchDemoStep) -> Void) {
        navigate(to: steps[0], apply: apply)
    }

    func requestFocusForCurrentStep(delay: Double = 0.45) {
        requestFocus(for: currentStep, delay: delay)
    }

    private func requestFocus(for step: PitchDemoStep, delay: Double) {
        focusedAnchor = step.focusAnchor
        focusToken += 1
        let request = PitchFocusRequest(anchor: step.focusAnchor, token: focusToken)

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.focusRequest = request
        }
    }
}

struct PitchFocusTarget: ViewModifier {
    @EnvironmentObject private var navigator: PitchDemoNavigatorState
    let id: String

    private var isFocused: Bool {
        navigator.focusedAnchor == id
    }

    func body(content: Content) -> some View {
        content
            .id(id)
            .overlay {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(isFocused ? DemoTheme.violet : Color.clear, lineWidth: 3)
                    .padding(-5)
            }
            .shadow(color: isFocused ? DemoTheme.violet.opacity(0.22) : .clear, radius: 18, x: 0, y: 10)
            .animation(.spring(response: 0.34, dampingFraction: 0.82), value: isFocused)
    }
}

extension View {
    func pitchFocusTarget(_ id: String) -> some View {
        modifier(PitchFocusTarget(id: id))
    }
}

struct PitchDemoController: View {
    @ObservedObject var navigator: PitchDemoNavigatorState
    let onApplyStep: (PitchDemoStep) -> Void

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                controlPill
                    .padding(.trailing, 14)
                    .padding(.bottom, 88)
            }
        }
        .sheet(isPresented: $navigator.showSheet) {
            PitchDemoStepSheet(navigator: navigator, onApplyStep: onApplyStep)
        }
    }

    private var controlPill: some View {
        HStack(spacing: 0) {
            Button {
                navigator.goBack(apply: onApplyStep)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(navigator.canGoBack ? .white : .white.opacity(0.3))
                    .frame(width: 40, height: 46)
            }
            .disabled(!navigator.canGoBack)

            Divider()
                .frame(height: 22)
                .overlay(.white.opacity(0.25))

            Button {
                navigator.showSheet = true
            } label: {
                VStack(spacing: 2) {
                    Text("PITCH \(navigator.currentStepIndex + 1) / \(navigator.steps.count)")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.62))
                        .tracking(0.6)
                    Text(navigator.currentStep.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                .frame(minWidth: 150)
                .padding(.horizontal, 8)
                .frame(height: 46)
            }

            Divider()
                .frame(height: 22)
                .overlay(.white.opacity(0.25))

            Button {
                navigator.advance(apply: onApplyStep)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(navigator.canGoForward ? .white : .white.opacity(0.3))
                    .frame(width: 40, height: 46)
            }
            .disabled(!navigator.canGoForward)
        }
        .background {
            Capsule()
                .fill(Color(hex: "0C1829").opacity(0.94))
        }
        .shadow(color: .black.opacity(0.26), radius: 18, x: 0, y: 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Pitch demo navigator, \(navigator.currentStep.title)")
    }
}

private struct PitchDemoStepSheet: View {
    @ObservedObject var navigator: PitchDemoNavigatorState
    let onApplyStep: (PitchDemoStep) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(navigator.steps) { step in
                        Button {
                            navigator.navigate(to: step, apply: onApplyStep)
                            dismiss()
                        } label: {
                            stepRow(step)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .background(LinearGradient.appBackground.ignoresSafeArea())
            .navigationTitle("Ashraf pitch path")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        navigator.reset(apply: onApplyStep)
                        dismiss()
                    } label: {
                        Label("Restart", systemImage: "arrow.counterclockwise")
                    }
                    .foregroundStyle(DemoTheme.coral)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func stepRow(_ step: PitchDemoStep) -> some View {
        let active = step.id == navigator.currentStepIndex

        return HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(active ? DemoTheme.violet : DemoTheme.violet.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: step.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(active ? .white : DemoTheme.violet)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Step \(step.id + 1)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(DemoTheme.secondary)
                    Text(step.role.title)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(step.role == .medicalAid ? DemoTheme.mint : step.role == .clinician ? DemoTheme.blue : DemoTheme.coral)
                    Spacer()
                    if active {
                        Text("CURRENT")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .tracking(0.5)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(DemoTheme.violet)
                            .clipShape(Capsule())
                    }
                }

                Text(step.title)
                    .font(.headline)
                    .foregroundStyle(DemoTheme.ink)
                Text(step.cue)
                    .font(.subheadline)
                    .foregroundStyle(DemoTheme.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(16)
        .background(active ? DemoTheme.violet.opacity(0.07) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(active ? DemoTheme.violet.opacity(0.3) : Color.clear, lineWidth: 1.5)
        }
    }
}
