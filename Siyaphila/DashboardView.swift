import SwiftUI
import Combine

struct PatientRootView: View {
    let patient: PatientProfile
    @Binding var selectedTab: Int
    let onExit: () -> Void
    @StateObject private var store: PatientDemoStore

    init(patient: PatientProfile, selectedTab: Binding<Int>, onExit: @escaping () -> Void) {
        self.patient = patient
        self._selectedTab = selectedTab
        self.onExit = onExit
        _store = StateObject(wrappedValue: PatientDemoStore(patient: patient))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView(store: store) {
                    selectedTab = 1
                }
            }
            .tag(0)
            .tabItem { Label("Home", systemImage: "house.fill") }

            NavigationStack {
                TodayMedicationView(store: store)
            }
            .tag(1)
            .tabItem { Label("Today", systemImage: "checklist") }

            NavigationStack {
                ConditionsMedicationsView(store: store)
            }
            .tag(2)
            .tabItem { Label("Meds", systemImage: "pills.fill") }

            NavigationStack {
                CoachCenterView(store: store)
            }
            .tag(3)
            .tabItem { Label("Coach", systemImage: "sparkles") }

            NavigationStack {
                CareJourneyView(store: store)
            }
            .tag(4)
            .tabItem { Label("Care", systemImage: "calendar.badge.clock") }
        }
        .tint(DemoTheme.violet)
        .overlay(alignment: .topLeading) {
            BackToEcosystemButton(action: onExit)
                .padding(.leading, 16)
                .padding(.top, 6)
        }
    }
}

struct DashboardView: View {
    @ObservedObject var store: PatientDemoStore
    let onOpenToday: () -> Void
    @EnvironmentObject private var pitchNavigator: PitchDemoNavigatorState

    private var patient: PatientProfile { store.patient }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    hero
                    nextActionCard
                    ringSection
                    highlightSection
                        .pitchFocusTarget("patientRisk")
                    dueTodaySection
                    aiInsightSection
                    conditionSummarySection
                }
                .padding(20)
            }
            .background(LinearGradient.appBackground.ignoresSafeArea())
            .navigationTitle("Patient App")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(pitchNavigator.$focusRequest.compactMap { $0 }) { request in
                guard request.anchor == "patientRisk" else { return }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
                    proxy.scrollTo(request.anchor, anchor: .center)
                }
            }
        }
    }

    private var hero: some View {
        GradientHeroCard(colors: [Color(hex: "FF7A59"), Color(hex: "FF9B5E"), Color(hex: "FFC05E")]) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    StatusChip(title: patient.riskBanner, color: .white, icon: "waveform.path.ecg")
                    Spacer()
                    Image(systemName: patient.avatar)
                        .font(.system(size: 30))
                        .foregroundStyle(.white)
                }

                Text(patient.name)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(patient.heroSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.84))

                HStack(spacing: 12) {
                    HeroStat(title: "Adherence score", value: "\(patient.adherenceScore)%")
                    HeroStat(title: "Current streak", value: "\(patient.streak) days")
                }

                HStack(spacing: 10) {
                    StatusChip(title: "Follow-up \(patient.followUpDate)", color: .white, icon: "stethoscope")
                    StatusChip(title: "Renewal \(patient.scriptRenewalDate)", color: .white, icon: "calendar.badge.clock")
                    if store.proofStage == .verified {
                        StatusChip(title: "Proof verified", color: .white, icon: "camera.aperture")
                    }
                }
            }
        }
    }

    private var nextActionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("Today", subtitle: "The fastest way to log what’s due right now.")

            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(store.todayProgressText)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(DemoTheme.ink)
                    Text(nextActionSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(DemoTheme.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text("\(store.dueTaskCount)")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(DemoTheme.amber)
                    Text("still due")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DemoTheme.secondary)
                }
            }

            HStack(spacing: 10) {
                Button(action: onOpenToday) {
                    Text("Log now")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(DemoTheme.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .buttonStyle(.plain)

                if let nextTask = store.nextPriorityTask {
                    Button {
                        store.snooze(nextTask)
                    } label: {
                        Text("Remind in 15")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(DemoTheme.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(DemoTheme.blue.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .surfaceCard()
    }

    private var ringSection: some View {
        HStack(spacing: 14) {
            ProgressRing(title: "Adherence", value: patient.adherenceScore, tint: DemoTheme.mint)
                .frame(maxWidth: .infinity)
            ProgressRing(title: "Care", value: patient.careScore, tint: DemoTheme.violet)
                .frame(maxWidth: .infinity)
            ProgressRing(title: "Engage", value: patient.engagementScore, tint: DemoTheme.blue)
                .frame(maxWidth: .infinity)
        }
        .surfaceCard()
    }

    private var highlightSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("Today’s highlights", subtitle: "The most important story points for a live demo.")

            HighlightRow(
                icon: "exclamationmark.triangle.fill",
                tint: patient.riskLevel.color,
                title: "Risk rising",
                message: "Ayo’s disease control may be worsening because adherence is inconsistent, especially around evening doses."
            )

            HighlightRow(
                icon: "flame.fill",
                tint: DemoTheme.amber,
                title: "Streak status",
                message: "The current streak is only \(patient.streak) days. \(store.openNudgesCount) support prompts are still open for today."
            )

            HighlightRow(
                icon: "brain.head.profile",
                tint: DemoTheme.violet,
                title: "Care insight",
                message: "Follow-up review can help determine whether poor control is due to non-adherence rather than medication failure."
            )
        }
        .surfaceCard()
    }

    private var dueTodaySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader("Meds due today", subtitle: "Today’s doses and where support is needed.")
            ForEach(patient.todayTasks.prefix(2)) { task in
                let taskStatus = store.status(for: task)

                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 14) {
                        Circle()
                            .fill(taskStatus.color.opacity(0.15))
                            .frame(width: 46, height: 46)
                            .overlay {
                                Image(systemName: taskStatus == .taken ? "checkmark.circle.fill" : taskStatus == .missed ? "exclamationmark.circle.fill" : "bell.badge.fill")
                                    .foregroundStyle(taskStatus.color)
                            }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.medicationName)
                                .font(.headline)
                                .foregroundStyle(DemoTheme.ink)
                            Text("\(task.time) • \(task.context)")
                                .font(.subheadline)
                                .foregroundStyle(DemoTheme.secondary)
                            Text(store.note(for: task))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(taskStatus.color)
                        }

                        Spacer()

                        StatusChip(title: taskStatus.label, color: taskStatus.color, icon: "clock.fill")
                    }

                    HStack(spacing: 10) {
                        TaskActionButton(title: "Taken", tint: DemoTheme.mint, isSelected: taskStatus == .taken) {
                            store.setStatus(for: task, to: .taken)
                        }
                        TaskActionButton(title: "Due", tint: DemoTheme.amber, isSelected: taskStatus == .due) {
                            store.setStatus(for: task, to: .due)
                        }
                        TaskActionButton(title: "Missed", tint: DemoTheme.coral, isSelected: taskStatus == .missed) {
                            store.setStatus(for: task, to: .missed)
                        }
                    }
                }
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }

            Button(action: onOpenToday) {
                HStack {
                    Text("Open full day view")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(DemoTheme.blue)
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundStyle(DemoTheme.blue)
                }
                .padding(18)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    private var aiInsightSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader("AI coach insight", subtitle: "A believable demo of where risk and support come together.")

            VStack(alignment: .leading, spacing: 14) {
                StatusChip(title: patient.riskLevel.label + " risk", color: patient.riskLevel.color, icon: "sparkles")
                Text(patient.coachInsight)
                    .font(.headline)
                    .foregroundStyle(DemoTheme.ink)
                HStack(spacing: 14) {
                    MetricTile(title: "Follow-up due", value: patient.followUpDate, subtitle: "Clinician review", tint: DemoTheme.blue, icon: "stethoscope")
                    MetricTile(title: "Script renewal", value: patient.scriptRenewalDate, subtitle: store.renewalReminderEnabled ? "Reminder active" : "Reminder paused", tint: DemoTheme.coral, icon: "arrow.triangle.2.circlepath")
                }
            }
            .surfaceCard()
        }
    }

    private var conditionSummarySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader("Conditions at a glance", subtitle: "All current chronic conditions in one view.")
            ForEach(patient.conditions) { condition in
                HStack(alignment: .top, spacing: 14) {
                    Circle()
                        .fill(DemoTheme.blue.opacity(0.1))
                        .frame(width: 44, height: 44)
                        .overlay {
                            Image(systemName: condition.icon)
                                .foregroundStyle(DemoTheme.blue)
                        }
                    VStack(alignment: .leading, spacing: 5) {
                        Text(condition.name)
                            .font(.headline)
                            .foregroundStyle(DemoTheme.ink)
                        Text(condition.subtitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(DemoTheme.secondary)
                        Text(condition.careNote)
                            .font(.subheadline)
                            .foregroundStyle(DemoTheme.secondary)
                    }
                    Spacer()
                }
                .padding(18)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
        }
    }
}

private extension DashboardView {
    var nextActionSubtitle: String {
        if let nextTask = store.nextPriorityTask {
            return "Next: \(nextTask.medicationName) at \(nextTask.time) • \(nextTask.context)"
        }
        return "All planned doses are logged for today."
    }
}

struct TaskActionButton: View {
    let title: String
    let tint: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(isSelected ? .white : tint)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? tint : tint.opacity(0.12))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct HighlightRow: View {
    let icon: String
    let tint: Color
    let title: String
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.14))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundStyle(tint)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(DemoTheme.ink)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(DemoTheme.secondary)
            }
            Spacer()
        }
    }
}

private struct HeroStat: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.72))
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct BackToEcosystemButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                Text("Roles")
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(DemoTheme.ink)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
    }
}

#Preview {
    PatientRootView(patient: DemoData.ayo, selectedTab: .constant(0), onExit: {})
}
