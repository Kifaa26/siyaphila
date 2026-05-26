import SwiftUI
import Combine

struct CoachCenterView: View {
    @ObservedObject var store: PatientDemoStore
    @State private var showingAcknowledged = false

    private var patient: PatientProfile { store.patient }

    private var visibleNudges: [CoachNudge] {
        patient.nudges.filter { showingAcknowledged || !store.isAcknowledged($0) }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                GradientHeroCard(colors: [Color(hex: "1B2250"), Color(hex: "4A49D3"), Color(hex: "7A63FF")]) {
                    VStack(alignment: .leading, spacing: 14) {
                        StatusChip(title: "AI coach", color: .white, icon: "sparkles")
                        Text("Support that feels\npersonal and timely.")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Believable nudges, streak recovery, follow-up reminders, and support planning around Ayo’s actual behavior pattern.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.82))
                    }
                }

                HStack(spacing: 14) {
                    MetricTile(title: "Risk level", value: patient.riskLevel.label, subtitle: "Current support priority", tint: patient.riskLevel.color, icon: "waveform.path.ecg")
                    MetricTile(title: "Open nudges", value: "\(store.openNudgesCount)", subtitle: showingAcknowledged ? "Showing all nudges" : "Needs action", tint: DemoTheme.blue, icon: "stethoscope")
                }

                HStack(spacing: 10) {
                    TaskFilterButton(title: "Open", isSelected: !showingAcknowledged) {
                        showingAcknowledged = false
                    }
                    TaskFilterButton(title: "All", isSelected: showingAcknowledged) {
                        showingAcknowledged = true
                    }
                }

                ForEach(visibleNudges) { nudge in
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top, spacing: 14) {
                            Circle()
                                .fill(nudge.tone.color.opacity(0.14))
                                .frame(width: 44, height: 44)
                                .overlay {
                                    Image(systemName: nudge.tone.icon)
                                        .foregroundStyle(nudge.tone.color)
                                }

                            VStack(alignment: .leading, spacing: 5) {
                                Text(nudge.title)
                                    .font(.headline)
                                    .foregroundStyle(DemoTheme.ink)
                                Text(nudge.body)
                                    .font(.subheadline)
                                    .foregroundStyle(DemoTheme.secondary)
                            }
                            Spacer()
                        }

                        HStack(spacing: 10) {
                            TaskFilterButton(
                                title: store.isAcknowledged(nudge) ? "Acknowledged" : "Mark done",
                                isSelected: store.isAcknowledged(nudge)
                            ) {
                                store.acknowledge(nudge)
                            }

                            if nudge.title.localizedCaseInsensitiveContains("follow-up") {
                                TaskFilterButton(title: store.followUpConfirmed ? "Visit booked" : "Book follow-up", isSelected: store.followUpConfirmed) {
                                    store.followUpConfirmed.toggle()
                                }
                            }
                        }
                    }
                    .surfaceCard()
                }
            }
            .padding(20)
        }
        .background(LinearGradient.appBackground.ignoresSafeArea())
        .navigationTitle("AI Coach")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct TaskFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(isSelected ? .white : DemoTheme.blue)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isSelected ? DemoTheme.blue : DemoTheme.blue.opacity(0.12))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct ClinicianRootView: View {
    let patient: PatientProfile
    let snapshot: ClinicianSnapshot
    @Binding var selectedTab: Int
    let onExit: () -> Void
    @State private var selectedCaseID: UUID = DemoData.clinicianCases.first?.id ?? UUID()

    private var selectedCase: ClinicianCase {
        DemoData.clinicianCases.first(where: { $0.id == selectedCaseID }) ?? DemoData.clinicianCases[0]
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ClinicianOverviewView(selectedCaseID: $selectedCaseID)
            }
            .tag(0)
            .tabItem { Label("Overview", systemImage: "person.text.rectangle") }

            NavigationStack {
                PrescribingManagementView(selectedCaseID: $selectedCaseID)
            }
            .tag(1)
            .tabItem { Label("Prescribe", systemImage: "cross.case.fill") }

            NavigationStack {
                AdherenceReviewView(selectedCaseID: $selectedCaseID)
            }
            .tag(2)
            .tabItem { Label("Review", systemImage: "chart.line.uptrend.xyaxis") }
        }
        .tint(DemoTheme.blue)
        .overlay(alignment: .topLeading) {
            BackToEcosystemButton(action: onExit)
                .padding(.leading, 16)
                .padding(.top, 6)
        }
    }
}

struct ClinicianOverviewView: View {
    @Binding var selectedCaseID: UUID

    private var selectedCase: ClinicianCase {
        DemoData.clinicianCases.first(where: { $0.id == selectedCaseID }) ?? DemoData.clinicianCases[0]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                GradientHeroCard(colors: [Color(hex: "10203B"), Color(hex: "244FC8"), Color(hex: "2F8CFF")]) {
                    VStack(alignment: .leading, spacing: 14) {
                        StatusChip(title: "Clinician dashboard", color: .white, icon: "stethoscope")
                        Text("\(selectedCase.patient.name) • clinician view")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(selectedCase.snapshot.patientSummary)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.82))
                    }
                }

                clinicianRoster

                HStack(spacing: 14) {
                    MetricTile(title: "Adherence score", value: "\(selectedCase.patient.adherenceScore)%", subtitle: "App-captured behavior", tint: DemoTheme.blue, icon: "chart.bar.fill")
                    MetricTile(title: "Risk band", value: selectedCase.patient.riskLevel.label, subtitle: selectedCase.queueLabel, tint: selectedCase.patient.riskLevel.color, icon: "waveform.path.ecg")
                }

                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader("Current medications", subtitle: "What the clinician can see at a glance before deciding whether to intensify treatment.")
                    ForEach(selectedCase.patient.medications) { medication in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(medication.name)
                                    .font(.headline)
                                    .foregroundStyle(DemoTheme.ink)
                                Text("\(medication.dose) • \(medication.schedule)")
                                    .font(.subheadline)
                                    .foregroundStyle(DemoTheme.secondary)
                            }
                            Spacer()
                            StatusChip(title: medication.timing, color: medication.color, icon: "clock.fill")
                        }
                        .surfaceCard()
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader("Diagnoses", subtitle: "Current chronic disease list and working notes.")
                    ForEach(selectedCase.snapshot.diagnoses) { diagnosis in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(diagnosis.name)
                                .font(.headline)
                                .foregroundStyle(DemoTheme.ink)
                            Text(diagnosis.note)
                                .font(.subheadline)
                                .foregroundStyle(DemoTheme.secondary)
                        }
                        .surfaceCard()
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader("Clinical interpretation", subtitle: "How adherence changes the read of poor control.")
                    Text(selectedCase.snapshot.assessment)
                        .font(.headline)
                        .foregroundStyle(DemoTheme.ink)
                        .surfaceCard()
                }
            }
            .padding(20)
        }
        .background(LinearGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Clinician")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var clinicianRoster: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader("Patient roster", subtitle: "Select a case to update the dashboard.")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(DemoData.clinicianCases) { caseItem in
                        Button {
                            selectedCaseID = caseItem.id
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(caseItem.patient.name)
                                    .font(.headline)
                                    .foregroundStyle(caseItem.id == selectedCaseID ? .white : DemoTheme.ink)
                                Text("\(caseItem.patient.adherenceScore)% adherence")
                                    .font(.subheadline)
                                    .foregroundStyle(caseItem.id == selectedCaseID ? .white.opacity(0.78) : DemoTheme.secondary)
                                StatusChip(
                                    title: caseItem.patient.riskLevel.label,
                                    color: caseItem.id == selectedCaseID ? .white : caseItem.patient.riskLevel.color,
                                    icon: "waveform.path.ecg"
                                )
                            }
                            .padding(18)
                            .frame(width: 210, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .fill(caseItem.id == selectedCaseID ? AnyShapeStyle(LinearGradient(colors: [Color(hex: "244FC8"), Color(hex: "6B63FF")], startPoint: .topLeading, endPoint: .bottomTrailing)) : AnyShapeStyle(Color.white))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct PrescribingManagementView: View {
    @Binding var selectedCaseID: UUID
    @State private var selectedDiagnosis: String = "Type 2 Diabetes"
    @State private var selectedMedication: String = "Metformin"
    @State private var selectedDose: String = "1 g"
    @State private var selectedFrequency: String = "Twice daily with meals"
    @State private var selectedDuration: String = "30 days"
    @State private var selectedFollowUp: String = "27 Apr"

    private var selectedCase: ClinicianCase {
        DemoData.clinicianCases.first(where: { $0.id == selectedCaseID }) ?? DemoData.clinicianCases[0]
    }

    private let diagnosisOptions = ["Type 2 Diabetes", "Hypertension", "Dyslipidaemia", "Heart Failure", "Asthma"]
    private let medicationOptions = ["Metformin", "Amlodipine", "Atorvastatin", "Furosemide", "Bisoprolol", "Budesonide/Formoterol"]
    private let doseOptions = ["500 mg", "1 g", "5 mg", "10 mg", "20 mg", "40 mg", "2 puffs"]
    private let frequencyOptions = ["Every morning", "Twice daily with meals", "Every evening", "Twice daily", "Every morning with food"]
    private let durationOptions = ["14 days", "30 days", "60 days", "90 days"]
    private let followUpOptions = ["23 Apr", "27 Apr", "29 Apr", "06 May", "13 May"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                GradientHeroCard(colors: [Color(hex: "11203B"), Color(hex: "2550C7"), Color(hex: "33A4FF")]) {
                    VStack(alignment: .leading, spacing: 14) {
                        StatusChip(title: "UI-only prescribing flow", color: .white, icon: "cross.case.fill")
                        Text("Diagnosis, prescribing,\nand review in one workflow.")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("This screen shows how a clinician could add diagnoses, prescribe medication, set duration, and plan the next follow-up.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.82))
                    }
                }

                MenuSelectionStrip(selectedCaseID: $selectedCaseID)

                SectionHeader("Prescribing & condition management", subtitle: "UI-only workflow for diagnosis, medication setup, script duration, and follow-up.")

                VStack(alignment: .leading, spacing: 14) {
                    InteractiveFormRow(label: "Add diagnosis", selection: $selectedDiagnosis, options: diagnosisOptions)
                    InteractiveFormRow(label: "Prescribe medication", selection: $selectedMedication, options: medicationOptions)
                    InteractiveFormRow(label: "Dose", selection: $selectedDose, options: doseOptions)
                    InteractiveFormRow(label: "Frequency", selection: $selectedFrequency, options: frequencyOptions)
                    InteractiveFormRow(label: "Script duration", selection: $selectedDuration, options: durationOptions)
                    InteractiveFormRow(label: "Next follow-up", selection: $selectedFollowUp, options: followUpOptions)
                }
                .surfaceCard()

                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader("Draft order summary", subtitle: "Selections update live to simulate a working prescribing flow.")
                    VStack(alignment: .leading, spacing: 8) {
                        Text(selectedCase.patient.name)
                            .font(.headline)
                            .foregroundStyle(DemoTheme.ink)
                        Text("\(selectedDiagnosis) • \(selectedMedication) \(selectedDose)")
                            .font(.subheadline)
                            .foregroundStyle(DemoTheme.secondary)
                        Text("\(selectedFrequency) • \(selectedDuration) • review \(selectedFollowUp)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(DemoTheme.blue)
                    }
                    .surfaceCard()
                }

                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader("Current prescriptions", subtitle: "A believable prescribing summary for the demo.")
                    ForEach(selectedCase.snapshot.prescriptions) { prescription in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(prescription.medicationName)
                                .font(.headline)
                                .foregroundStyle(DemoTheme.ink)
                            Text("\(prescription.dosage) • \(prescription.frequency)")
                                .font(.subheadline)
                                .foregroundStyle(DemoTheme.secondary)
                            HStack(spacing: 10) {
                                StatusChip(title: prescription.scriptDuration, color: DemoTheme.blue, icon: "calendar")
                                StatusChip(title: "Review \(prescription.followUpDate)", color: DemoTheme.violet, icon: "stethoscope")
                            }
                        }
                        .surfaceCard()
                    }
                }
            }
            .padding(20)
        }
        .background(LinearGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Prescribing")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AdherenceReviewView: View {
    @Binding var selectedCaseID: UUID
    @EnvironmentObject private var pitchNavigator: PitchDemoNavigatorState

    private var selectedCase: ClinicianCase {
        DemoData.clinicianCases.first(where: { $0.id == selectedCaseID }) ?? DemoData.clinicianCases[0]
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                GradientHeroCard(colors: [Color(hex: "13203B"), Color(hex: "3255B8"), Color(hex: "6B63FF")]) {
                    VStack(alignment: .leading, spacing: 14) {
                        StatusChip(title: "Adherence review", color: .white, icon: "chart.line.uptrend.xyaxis")
                        Text("Poor control may be\nbehavior, not failure.")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Use adherence trends, missed-dose patterns, and barrier notes to decide whether medication escalation is truly needed.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.82))
                    }
                }

                MenuSelectionStrip(selectedCaseID: $selectedCaseID)

                SectionHeader("Adherence review", subtitle: "Trend, missed-dose pattern, barrier notes, and next-step recommendation.")

                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .bottom, spacing: 12) {
                        ForEach(selectedCase.patient.trend) { point in
                            VStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(LinearGradient(colors: [DemoTheme.blue.opacity(0.75), DemoTheme.violet], startPoint: .bottom, endPoint: .top))
                                    .frame(height: max(CGFloat(point.value) * 1.5, 24))
                                Text(point.label)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(DemoTheme.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 170, alignment: .bottom)

                    Text("Monthly adherence trend shows persistent underperformance with partial recovery but no sustained stabilization.")
                        .font(.subheadline)
                        .foregroundStyle(DemoTheme.secondary)
                }
                .surfaceCard()

                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader("Monthly adherence calendar", subtitle: "A clinician-friendly view of complete, partial, and missed days.")
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(["M","T","W","T","F","S","S"], id: \.self) { day in
                            Text(day)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(DemoTheme.secondary)
                        }

                        ForEach(selectedCase.patient.adherenceDays) { day in
                            ZStack {
                                Circle()
                                    .fill(day.status.color.opacity(0.16))
                                    .frame(width: 34, height: 34)
                                Circle()
                                    .stroke(day.status.color.opacity(0.5), lineWidth: 1.2)
                                    .frame(width: 34, height: 34)
                                Text("\(day.day)")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(DemoTheme.ink)
                            }
                        }
                    }
                    .surfaceCard()
                }

                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader("Barrier notes", subtitle: "Potential reasons poor control may reflect behavior rather than medication failure.")
                    ForEach(selectedCase.patient.barrierNotes) { note in
                        HStack(alignment: .top, spacing: 12) {
                            Circle()
                                .fill(note.severity.color.opacity(0.12))
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundStyle(note.severity.color)
                                }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.title)
                                    .font(.headline)
                                    .foregroundStyle(DemoTheme.ink)
                                Text(note.body)
                                    .font(.subheadline)
                                    .foregroundStyle(DemoTheme.secondary)
                            }
                        }
                        .surfaceCard()
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader("Follow-up recommendation")
                    Text(selectedCase.snapshot.recommendation)
                        .font(.headline)
                        .foregroundStyle(DemoTheme.ink)
                        .surfaceCard()
                }
                .pitchFocusTarget("clinicianDecision")
                }
                .padding(20)
            }
            .background(LinearGradient.appBackground.ignoresSafeArea())
            .navigationTitle("Adherence Review")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(pitchNavigator.$focusRequest.compactMap { $0 }) { request in
                guard request.anchor == "clinicianDecision" else { return }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
                    proxy.scrollTo(request.anchor, anchor: .center)
                }
            }
        }
    }
}

struct MedicalAidRootView: View {
    let patient: PatientProfile
    let analytics: AnalyticsSnapshot
    @Binding var selectedTab: Int
    let onExit: () -> Void

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                MedicalAidAnalyticsView(patient: patient, analytics: analytics)
            }
            .tag(0)
            .tabItem { Label("Analytics", systemImage: "chart.xyaxis.line") }

            NavigationStack {
                PredictiveCareView(analytics: analytics)
            }
            .tag(1)
            .tabItem { Label("Predictive AI", systemImage: "brain.head.profile") }
        }
        .tint(DemoTheme.mint)
        .overlay(alignment: .topLeading) {
            BackToEcosystemButton(action: onExit)
                .padding(.leading, 16)
                .padding(.top, 6)
        }
    }
}

struct MedicalAidAnalyticsView: View {
    let patient: PatientProfile
    let analytics: AnalyticsSnapshot
    @EnvironmentObject private var pitchNavigator: PitchDemoNavigatorState

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                GradientHeroCard(colors: [Color(hex: "0F2940"), Color(hex: "1A506A"), Color(hex: "35C98A")]) {
                    VStack(alignment: .leading, spacing: 14) {
                        StatusChip(title: "Medical aid analytics", color: .white, icon: "chart.line.text.clipboard")
                        Text("Adherence becomes population intelligence.")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Track stable, rising, high, and critical members, quantify avoidable spend, and prioritize earlier outreach across the covered population.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.82))
                    }
                }

                HStack(spacing: 14) {
                    MetricTile(title: "Projected savings", value: analytics.projectedSavings, subtitle: "Early intervention opportunity", tint: DemoTheme.mint, icon: "banknote.fill")
                    MetricTile(title: "Avoidable spend", value: analytics.avoidableSpend, subtitle: "If risk is missed", tint: DemoTheme.coral, icon: "exclamationmark.triangle.fill")
                }
                .pitchFocusTarget("medicalAidSpend")

                HStack(spacing: 14) {
                    MetricTile(title: "Outreach queue", value: "\(analytics.outreachQueueCount)", subtitle: "Members needing action", tint: DemoTheme.blue, icon: "person.3.fill")
                    MetricTile(title: "Renewal risk", value: "\(analytics.renewalRiskCount)", subtitle: "Renewal-related gaps", tint: DemoTheme.amber, icon: "calendar.badge.clock")
                }

                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader("Risk trend", subtitle: "A clean investor-friendly read of the current direction of the covered population.")
                    HStack(alignment: .bottom, spacing: 12) {
                        ForEach(analytics.trends) { point in
                            VStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(LinearGradient(colors: [DemoTheme.mint.opacity(0.85), DemoTheme.blue.opacity(0.75)], startPoint: .bottom, endPoint: .top))
                                    .frame(height: max(CGFloat(point.value) * 2.2, 24))
                                Text(point.label)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(DemoTheme.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 190, alignment: .bottom)

                    Text("Population adherence risk is trending in the wrong direction, which is exactly where early outreach, renewal support, and predictive intervention become valuable.")
                        .font(.subheadline)
                        .foregroundStyle(DemoTheme.secondary)
                }
                .surfaceCard()

                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader("Risk mix", subtitle: "Stable, rising, high, and critical members.")
                    ForEach(analytics.distribution) { point in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(point.label)
                                    .font(.headline)
                                    .foregroundStyle(DemoTheme.ink)
                                Spacer()
                                Text("\(point.value)")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(point.color)
                            }
                            ProgressView(value: Double(point.value), total: Double(analytics.coveredLives))
                                .tint(point.color)
                        }
                        .surfaceCard()
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader("Outreach queue", subtitle: "A fast, demo-friendly read of who needs intervention.")
                    ForEach(analytics.outreachQueue) { member in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(member.name)
                                        .font(.headline)
                                        .foregroundStyle(DemoTheme.ink)
                                    Text(member.condition)
                                        .font(.subheadline)
                                        .foregroundStyle(DemoTheme.secondary)
                                }
                                Spacer()
                                StatusChip(title: member.riskLevel.label, color: member.riskLevel.color, icon: "waveform.path.ecg")
                            }
                            HStack(spacing: 12) {
                                MetricTile(title: "Adherence", value: "\(member.adherenceScore)%", subtitle: member.refillRisk, tint: DemoTheme.blue, icon: "chart.bar.fill")
                                MetricTile(title: "Opportunity", value: member.opportunity, subtitle: "Potential savings", tint: DemoTheme.mint, icon: "banknote.fill")
                            }
                        }
                        .surfaceCard()
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader("AI-generated population insights")
                    ForEach(analytics.insights) { insight in
                        HStack(alignment: .top, spacing: 14) {
                            Circle()
                                .fill(DemoTheme.mint.opacity(0.14))
                                .frame(width: 42, height: 42)
                                .overlay {
                                    Image(systemName: insight.icon)
                                        .foregroundStyle(DemoTheme.mint)
                                }
                            VStack(alignment: .leading, spacing: 5) {
                                Text(insight.title)
                                    .font(.headline)
                                    .foregroundStyle(DemoTheme.ink)
                                Text(insight.detail)
                                    .font(.subheadline)
                                    .foregroundStyle(DemoTheme.secondary)
                            }
                        }
                        .surfaceCard()
                    }
                }
                }
                .padding(20)
            }
            .background(LinearGradient.appBackground.ignoresSafeArea())
            .navigationTitle("Medical Aid")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(pitchNavigator.$focusRequest.compactMap { $0 }) { request in
                guard request.anchor == "medicalAidSpend" else { return }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
                    proxy.scrollTo(request.anchor, anchor: .center)
                }
            }
        }
    }
}

struct PredictiveCareView: View {
    let analytics: AnalyticsSnapshot
    @EnvironmentObject private var pitchNavigator: PitchDemoNavigatorState

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                GradientHeroCard(colors: [Color(hex: "121D3B"), Color(hex: "3E4FBE"), Color(hex: "7A63FF")]) {
                    VStack(alignment: .leading, spacing: 14) {
                        StatusChip(title: "Predictive care", color: .white, icon: "brain.head.profile")
                        Text("From adherence data\nto personalized medicine.")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Diagnosis, medications, adherence, side effects, renewal behavior, and outcomes can become training data for future predictive models.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.82))
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader("Model inputs", subtitle: "What the platform captures over time.")
                    ForEach(analytics.predictiveInputs) { node in
                        PredictiveNodeCard(node: node)
                    }
                }
                .pitchFocusTarget("predictiveInputs")

                HStack {
                    Image(systemName: "arrow.down")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(DemoTheme.violet)
                    Text("Longitudinal data becomes trainable intelligence")
                        .font(.headline)
                        .foregroundStyle(DemoTheme.ink)
                    Spacer()
                }
                .surfaceCard()

                SectionHeader("Model outputs", subtitle: "What future predictive AI could generate.")
                ForEach(analytics.predictiveOutputs) { node in
                    PredictiveNodeCard(node: node)
                }
                }
                .padding(20)
            }
            .background(LinearGradient.appBackground.ignoresSafeArea())
            .navigationTitle("Predictive AI")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(pitchNavigator.$focusRequest.compactMap { $0 }) { request in
                guard request.anchor == "predictiveInputs" else { return }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
                    proxy.scrollTo(request.anchor, anchor: .top)
                }
            }
        }
    }
}

private struct PredictiveNodeCard: View {
    let node: PredictiveNode

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(node.color.opacity(0.14))
                .frame(width: 58, height: 58)
                .overlay {
                    Circle()
                        .fill(node.color)
                        .frame(width: 14, height: 14)
                }

            VStack(alignment: .leading, spacing: 5) {
                Text(node.title)
                    .font(.headline)
                    .foregroundStyle(DemoTheme.ink)
                Text(node.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(DemoTheme.secondary)
            }
            Spacer()
        }
        .surfaceCard()
    }
}

private struct FormRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(DemoTheme.secondary)
            HStack {
                Text(value)
                    .font(.headline)
                    .foregroundStyle(DemoTheme.ink)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundStyle(DemoTheme.secondary)
            }
            .padding(16)
            .background(Color(hex: "F4F7FD"))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}

private struct InteractiveFormRow: View {
    let label: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) {
                    selection = option
                }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(label)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DemoTheme.secondary)
                    Text(selection)
                        .font(.headline)
                        .foregroundStyle(DemoTheme.ink)
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundStyle(DemoTheme.secondary)
            }
            .padding(16)
            .background(Color(hex: "F4F7FD"))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct MenuSelectionStrip: View {
    @Binding var selectedCaseID: UUID

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader("Selected patient", subtitle: "Switch cases live during the demo.")
            Menu {
                ForEach(DemoData.clinicianCases) { caseItem in
                    Button(caseItem.patient.name) {
                        selectedCaseID = caseItem.id
                    }
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        let current = DemoData.clinicianCases.first(where: { $0.id == selectedCaseID }) ?? DemoData.clinicianCases[0]
                        Text(current.patient.name)
                            .font(.headline)
                            .foregroundStyle(DemoTheme.ink)
                        Text(current.queueLabel)
                            .font(.subheadline)
                            .foregroundStyle(DemoTheme.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.title3)
                        .foregroundStyle(DemoTheme.blue)
                }
                .padding(18)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ClinicianRootView(patient: DemoData.ayo, snapshot: DemoData.clinician, selectedTab: .constant(0), onExit: {})
}
