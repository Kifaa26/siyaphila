import SwiftUI

struct ProofOfDoseView: View {
    @ObservedObject var store: PatientDemoStore

    private var patient: PatientProfile { store.patient }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                mockCamera
                controlPanel
                HStack(spacing: 14) {
                    MetricTile(title: "Dose window", value: "20:00", subtitle: store.proofMedicationName, tint: DemoTheme.violet, icon: "clock.fill")
                    MetricTile(title: "Proof status", value: proofStatusTitle, subtitle: "Interactive demo flow", tint: DemoTheme.mint, icon: "flame.fill")
                }
                supportPanels
            }
            .padding(20)
        }
        .background(LinearGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Proof of Dose")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var mockCamera: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    LinearGradient(colors: [Color.black, Color(hex: "303C61"), Color(hex: "5B6B97")], startPoint: .top, endPoint: .bottom)
                )
                .frame(height: 500)

            VStack(spacing: 18) {
                HStack {
                    Text("20:00")
                        .font(.headline.weight(.semibold))
                    Spacer()
                    Label(store.proofUsingFrontCamera ? "Front camera" : "Rear camera", systemImage: "camera.fill")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 22)
                .padding(.top, 22)

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(.white.opacity(0.65), style: StrokeStyle(lineWidth: 1.5, dash: [8, 8]))
                        .frame(height: 230)

                    VStack(spacing: 12) {
                        Image(systemName: store.proofStage == .verified ? "checkmark.seal.fill" : "pill.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.white)
                        Text(frameTitle)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                        Text(frameSubtitle)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.78))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 18)
                    }
                }
                .padding(.horizontal, 22)

                HStack(spacing: 24) {
                    Button {
                        store.proofUsingFrontCamera.toggle()
                    } label: {
                        Circle()
                            .fill(.white.opacity(0.18))
                            .frame(width: 58, height: 58)
                            .overlay {
                                Image(systemName: store.proofUsingFrontCamera ? "camera.rotate.fill" : "bolt.fill")
                                    .foregroundStyle(.white)
                            }
                    }
                    .buttonStyle(.plain)

                    Button {
                        primaryProofAction()
                    } label: {
                        Circle()
                            .stroke(.white, lineWidth: 6)
                            .frame(width: 86, height: 86)
                            .overlay {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 66, height: 66)
                            }
                    }
                    .buttonStyle(.plain)

                    Button {
                        store.resetProof()
                    } label: {
                        Circle()
                            .fill(.white.opacity(0.18))
                            .frame(width: 58, height: 58)
                            .overlay {
                                Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                                    .foregroundStyle(.white)
                            }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 28)
            }
        }
    }

    private var controlPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader("Proof controls", subtitle: "Bring back the BeReal-style medication check-in as a live demo interaction.")

            Menu {
                ForEach(patient.medications, id: \.id) { medication in
                    Button(medication.name) {
                        store.proofMedicationName = medication.name
                    }
                }
            } label: {
                HStack {
                    Label(store.proofMedicationName, systemImage: "pills.fill")
                        .font(.headline)
                        .foregroundStyle(DemoTheme.ink)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundStyle(DemoTheme.secondary)
                }
                .padding(18)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }

            HStack(spacing: 10) {
                ProofActionChip(title: "Open camera", tint: DemoTheme.violet, isSelected: store.proofStage == .framing) {
                    store.openProofCamera()
                }
                ProofActionChip(title: "Capture", tint: DemoTheme.blue, isSelected: store.proofStage == .captured) {
                    store.captureProof()
                }
                ProofActionChip(title: "Verify dose", tint: DemoTheme.mint, isSelected: store.proofStage == .verified) {
                    store.verifyProof()
                }
            }
        }
    }

    private var supportPanels: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader("Why this helps", subtitle: "A visual interaction showing how adherence can feel visible, memorable, and trackable.")

            ProofCard(title: "Streak recovery", message: "A quick nightly proof moment makes evening doses feel more visible and memorable for \(patient.name.components(separatedBy: " ").first ?? patient.name).")
            ProofCard(title: "Clinician review", message: "A lightweight visual signal can support more informed follow-up when poor control may be driven by non-adherence.")
            ProofCard(title: "Adherence intelligence", message: "Repeated dose-proof behavior could eventually become another useful input into risk detection and support personalization.")
        }
    }

    private var proofStatusTitle: String {
        switch store.proofStage {
        case .ready: return "Ready"
        case .framing: return "Framing"
        case .captured: return "Captured"
        case .verified: return "Verified"
        }
    }

    private var frameTitle: String {
        switch store.proofStage {
        case .ready:
            return "Open the camera for tonight’s meds"
        case .framing:
            return "Hold \(store.proofMedicationName) in frame"
        case .captured:
            return "Review the captured dose check-in"
        case .verified:
            return "Dose verified and logged"
        }
    }

    private var frameSubtitle: String {
        switch store.proofStage {
        case .ready:
            return "Use a fast, BeReal-style proof moment to make medication-taking feel more deliberate."
        case .framing:
            return "Line up the medication and snap a quick proof-of-dose check-in."
        case .captured:
            return "Looks good. Confirm it to update today’s medication progress."
        case .verified:
            return "The proof interaction has updated the patient’s daily medication state for the demo."
        }
    }

    private func primaryProofAction() {
        switch store.proofStage {
        case .ready:
            store.openProofCamera()
        case .framing:
            store.captureProof()
        case .captured:
            store.verifyProof()
        case .verified:
            store.resetProof()
        }
    }
}

private struct ProofCard: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(DemoTheme.ink)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(DemoTheme.secondary)
        }
        .surfaceCard()
    }
}

private struct ProofActionChip: View {
    let title: String
    let tint: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(isSelected ? .white : tint)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(isSelected ? tint : tint.opacity(0.12))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ProofOfDoseView(store: PatientDemoStore(patient: DemoData.ayo))
    }
}
