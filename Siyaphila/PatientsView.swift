import SwiftUI
import Combine

struct TodayMedicationView: View {
    @ObservedObject var store: PatientDemoStore
    @State private var showProofFlow = false

    private var patient: PatientProfile { store.patient }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                GradientHeroCard(colors: [Color(hex: "0F203A"), Color(hex: "274D89"), Color(hex: "2F6BFF")]) {
                    VStack(alignment: .leading, spacing: 14) {
                        StatusChip(title: "Today’s medication plan", color: .white, icon: "checklist")
                        Text("One screen for every\ndose today.")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Log medication, snooze reminders, skip missed doses, and launch proof-of-dose without jumping between screens.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.82))
                    }
                }

                TodaySummaryStrip(store: store) {
                    if let task = store.nextPriorityTask {
                        store.openProofCamera(for: task)
                        showProofFlow = true
                    }
                }

                ForEach(store.groupedTasks, id: \.title) { group in
                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeader(group.title, subtitle: sectionSubtitle(for: group.tasks))
                        ForEach(group.tasks) { task in
                            TodayTaskCard(task: task, store: store) {
                                store.openProofCamera(for: task)
                                showProofFlow = true
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(LinearGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Today")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showProofFlow) {
            NavigationStack {
                ProofOfDoseView(store: store)
            }
        }
    }

    private func sectionSubtitle(for tasks: [MedicationTask]) -> String {
        let taken = tasks.filter { store.status(for: $0) == .taken }.count
        return "\(taken) of \(tasks.count) complete"
    }
}

struct ConditionsMedicationsView: View {
    @ObservedObject var store: PatientDemoStore
    @EnvironmentObject private var pitchNavigator: PitchDemoNavigatorState

    private var patient: PatientProfile { store.patient }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                GradientHeroCard(colors: [Color(hex: "10203B"), Color(hex: "2F55D4"), Color(hex: "6D63FF")]) {
                    VStack(alignment: .leading, spacing: 14) {
                        StatusChip(title: "Conditions and medications", color: .white, icon: "cross.case.fill")
                        Text("Everything Ayo is managing,\nin one place.")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Show the diagnoses, current chronic medications, plain-language guidance, and why daily adherence matters clinically.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.82))
                    }
                }

                SectionHeader("Conditions", subtitle: "Why each condition matters and how adherence supports control.")

                ForEach(patient.conditions) { condition in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label(condition.name, systemImage: condition.icon)
                                .font(.headline)
                                .foregroundStyle(DemoTheme.blue)
                            Spacer()
                            Text(condition.subtitle)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(DemoTheme.secondary)
                        }
                        Text(condition.summary)
                            .font(.subheadline)
                            .foregroundStyle(DemoTheme.secondary)
                        Text(condition.careNote)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(DemoTheme.ink)
                    }
                    .surfaceCard()
                }

                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeader("Medications", subtitle: "Patient-friendly guidance for what to take, when, and why.")

                        quickActions

                        ForEach(patient.medications) { medication in
                            NavigationLink {
                                MedicationDetailView(store: store, medication: medication)
                            } label: {
                                MedicationPreviewCard(store: store, medication: medication)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .pitchFocusTarget("medicationLiteracy")
                }
                .padding(20)
            }
            .background(LinearGradient.appBackground.ignoresSafeArea())
            .navigationTitle("Conditions & Meds")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(pitchNavigator.$focusRequest.compactMap { $0 }) { request in
                guard request.anchor == "medicationLiteracy" else { return }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
                    proxy.scrollTo(request.anchor, anchor: .top)
                }
            }
        }
    }

    private var quickActions: some View {
        HStack(spacing: 14) {
            Button {
                store.renewalReminderEnabled.toggle()
            } label: {
                InteractiveQuickTile(
                    title: "Script renewal",
                    value: store.renewalReminderEnabled ? "Reminder on" : "Reminder off",
                    subtitle: patient.scriptRenewalDate,
                    tint: DemoTheme.coral,
                    icon: "calendar.badge.clock"
                )
            }
            .buttonStyle(.plain)

            Button {
                store.followUpConfirmed.toggle()
            } label: {
                InteractiveQuickTile(
                    title: "Follow-up",
                    value: store.followUpConfirmed ? "Confirmed" : "Needs booking",
                    subtitle: patient.followUpDate,
                    tint: DemoTheme.blue,
                    icon: "stethoscope"
                )
            }
            .buttonStyle(.plain)
        }
    }
}

struct AdherenceCalendarView: View {
    @ObservedObject var store: PatientDemoStore
    private var patient: PatientProfile { store.patient }
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                GradientHeroCard(colors: [Color(hex: "0F203A"), Color(hex: "274D89"), Color(hex: "2F6BFF")]) {
                    VStack(alignment: .leading, spacing: 14) {
                        StatusChip(title: "Broken streak detected", color: .white, icon: "calendar.badge.exclamationmark")
                        Text("One month of adherence,\nshown visually.")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Ayo’s month shows repeated misses, partial days, and a visible pattern of risk building over time.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.82))
                    }
                }

                HStack(spacing: 10) {
                    ForEach(AdherenceStatus.allCases, id: \.self) { status in
                        StatusChip(title: status.rawValue.capitalized, color: status.color, icon: status.icon)
                    }
                }

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                        Text(day)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(DemoTheme.secondary)
                    }

                    ForEach(patient.adherenceDays) { day in
                        Button {
                            store.selectAdherenceDay(day.day)
                        } label: {
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(day.status.color.opacity(store.selectedAdherenceDay == day.day ? 0.26 : 0.16))
                                        .frame(width: 42, height: 42)
                                    Circle()
                                        .stroke(store.selectedAdherenceDay == day.day ? day.status.color : day.status.color.opacity(0.45), lineWidth: store.selectedAdherenceDay == day.day ? 2.5 : 1.5)
                                        .frame(width: 42, height: 42)
                                    Text("\(day.day)")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(DemoTheme.ink)
                                }
                                Image(systemName: day.status.icon)
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(day.status.color)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .surfaceCard()

                if let selectedDay = store.selectedAdherenceEntry {
                    SelectedDayCard(day: selectedDay)
                }

                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader("Pattern readout", subtitle: "What the calendar is saying at a glance.")
                    MetricTile(title: "Monthly adherence", value: "\(patient.adherenceScore)%", subtitle: "Below target for chronic care", tint: DemoTheme.coral, icon: "chart.bar.fill")
                    MetricTile(title: "Behavior pattern", value: "Evenings + weekends", subtitle: "Most missed doses cluster here", tint: DemoTheme.amber, icon: "moon.stars.fill")
                }
            }
            .padding(20)
        }
        .background(LinearGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Adherence Calendar")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FollowUpTimelineView: View {
    @ObservedObject var store: PatientDemoStore
    private var patient: PatientProfile { store.patient }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                GradientHeroCard(colors: [Color(hex: "12203B"), Color(hex: "23487B"), Color(hex: "35A6FF")]) {
                    VStack(alignment: .leading, spacing: 14) {
                        StatusChip(title: "Follow-up due soon", color: .white, icon: "calendar.badge.clock")
                        Text("A medication timeline\nthat feels real.")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Connect missed doses, script renewal, and clinician review into a single care journey judges can follow immediately.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.82))
                    }
                }

                SectionHeader("Follow-up timeline", subtitle: "Medication due, missed doses, script renewal, and doctor review in one flow.")

                HStack(spacing: 14) {
                    ToggleCard(
                        title: "Renewal reminder",
                        subtitle: patient.scriptRenewalDate,
                        isOn: store.renewalReminderEnabled,
                        tint: DemoTheme.coral
                    ) {
                        store.renewalReminderEnabled.toggle()
                    }
                    ToggleCard(
                        title: "Follow-up status",
                        subtitle: patient.followUpDate,
                        isOn: store.followUpConfirmed,
                        tint: DemoTheme.blue
                    ) {
                        store.followUpConfirmed.toggle()
                    }
                }

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(patient.timeline) { event in
                        HStack(alignment: .top, spacing: 14) {
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(event.status.color)
                                    .frame(width: 14, height: 14)
                                Rectangle()
                                    .fill(event.status.color.opacity(0.2))
                                    .frame(width: 2, height: 68)
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(event.title)
                                        .font(.headline)
                                        .foregroundStyle(DemoTheme.ink)
                                    Spacer()
                                    Text(event.dateLabel)
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(event.status.color)
                                }
                                Text(event.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(DemoTheme.secondary)
                            }
                        }
                    }
                }
                .surfaceCard()

                HStack(spacing: 14) {
                    MetricTile(title: "Next follow-up", value: patient.followUpDate, subtitle: "Review control and barriers", tint: DemoTheme.blue, icon: "stethoscope")
                    MetricTile(title: "Script renewal", value: patient.scriptRenewalDate, subtitle: "Renew before stock-out", tint: DemoTheme.coral, icon: "calendar.badge.clock")
                }
            }
            .padding(20)
        }
        .background(LinearGradient.appBackground.ignoresSafeArea())
        .navigationTitle("Timeline")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CareJourneyView: View {
    @ObservedObject var store: PatientDemoStore
    @EnvironmentObject private var pitchNavigator: PitchDemoNavigatorState
    private var patient: PatientProfile { store.patient }
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 7)

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                GradientHeroCard(colors: [Color(hex: "12203B"), Color(hex: "23487B"), Color(hex: "35A6FF")]) {
                    VStack(alignment: .leading, spacing: 14) {
                        StatusChip(title: "Care journey", color: .white, icon: "calendar.badge.clock")
                        Text("Adherence, follow-up,\nand renewal in one view.")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Show how daily medication behavior connects to renewal risk, clinician follow-up, and the month’s broader adherence story.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.82))
                    }
                }

                HStack(spacing: 14) {
                    ToggleCard(
                        title: "Renewal reminder",
                        subtitle: patient.scriptRenewalDate,
                        isOn: store.renewalReminderEnabled,
                        tint: DemoTheme.coral
                    ) {
                        store.renewalReminderEnabled.toggle()
                    }
                    ToggleCard(
                        title: "Follow-up status",
                        subtitle: patient.followUpDate,
                        isOn: store.followUpConfirmed,
                        tint: DemoTheme.blue
                    ) {
                        store.followUpConfirmed.toggle()
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        SectionHeader("Adherence calendar", subtitle: "Tap a day to inspect the pattern.")
                        Spacer()
                        StatusChip(title: patient.riskLevel.label, color: patient.riskLevel.color, icon: "waveform.path.ecg")
                    }

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                            Text(day)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(DemoTheme.secondary)
                        }

                        ForEach(patient.adherenceDays) { day in
                            Button {
                                store.selectAdherenceDay(day.day)
                            } label: {
                                VStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .fill(day.status.color.opacity(store.selectedAdherenceDay == day.day ? 0.26 : 0.16))
                                            .frame(width: 42, height: 42)
                                        Circle()
                                            .stroke(store.selectedAdherenceDay == day.day ? day.status.color : day.status.color.opacity(0.45), lineWidth: store.selectedAdherenceDay == day.day ? 2.5 : 1.5)
                                            .frame(width: 42, height: 42)
                                        Text("\(day.day)")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(DemoTheme.ink)
                                    }
                                    Image(systemName: day.status.icon)
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(day.status.color)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .surfaceCard()

                    if let selectedDay = store.selectedAdherenceEntry {
                        SelectedDayCard(day: selectedDay)
                    }
                }
                .pitchFocusTarget("adherenceCalendar")

                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader("Follow-up timeline", subtitle: "Medication due, missed doses, script renewal, and doctor review in one flow.")
                    ForEach(patient.timeline) { event in
                        HStack(alignment: .top, spacing: 14) {
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(event.status.color)
                                    .frame(width: 14, height: 14)
                                Rectangle()
                                    .fill(event.status.color.opacity(0.2))
                                    .frame(width: 2, height: 68)
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(event.title)
                                        .font(.headline)
                                        .foregroundStyle(DemoTheme.ink)
                                    Spacer()
                                    Text(event.dateLabel)
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(event.status.color)
                                }
                                Text(event.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(DemoTheme.secondary)
                            }
                        }
                    }
                }
                .surfaceCard()
                }
                .padding(20)
            }
            .background(LinearGradient.appBackground.ignoresSafeArea())
            .navigationTitle("Care")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(pitchNavigator.$focusRequest.compactMap { $0 }) { request in
                guard request.anchor == "adherenceCalendar" else { return }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
                    proxy.scrollTo(request.anchor, anchor: .top)
                }
            }
        }
    }
}

struct MedicationDetailView: View {
    @ObservedObject var store: PatientDemoStore
    let medication: Medication

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                GradientHeroCard(colors: [Color(hex: "10203B"), medication.color.opacity(0.95), medication.color]) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 10) {
                            StatusChip(title: medication.timing, color: .white, icon: "clock.fill")
                            StatusChip(title: medication.purpose, color: .white, icon: "cross.case.fill")
                        }
                        Text(medication.name)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("\(medication.dose) • \(medication.schedule)")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.82))
                        Text("Designed to feel simple, reassuring, and patient friendly while still communicating clinical seriousness.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.76))
                    }
                }

                HStack(spacing: 14) {
                    RichInfoTile(title: "Dose", value: medication.dose, subtitle: medication.schedule, tint: medication.color, icon: "pills.fill")
                    RichInfoTile(title: "Timing", value: medication.timing, subtitle: "Link it to a consistent routine", tint: DemoTheme.blue, icon: "clock.fill")
                }

                DoseTrackerCard(store: store, medication: medication)

                InfoPanel(title: "What it is for", message: medication.purpose, tint: medication.color)
                InfoPanel(title: "How to take it", message: medication.howToTake, tint: DemoTheme.blue)
                InfoPanel(title: "Why it matters", message: medication.whyItMatters, tint: DemoTheme.coral)
                InfoPanel(title: "Patient-friendly explanation", message: medication.patientExplanation, tint: DemoTheme.violet)
            }
            .padding(20)
        }
        .background(LinearGradient.appBackground.ignoresSafeArea())
        .navigationTitle(medication.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct MedicationPreviewCard: View {
    @ObservedObject var store: PatientDemoStore
    let medication: Medication

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                StatusChip(title: medication.timing, color: medication.color, icon: "clock.fill")
                Spacer()
                Image(systemName: "arrow.up.right.circle.fill")
                    .font(.title3)
                    .foregroundStyle(medication.color)
            }

            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [medication.color.opacity(0.18), medication.color.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                    .overlay {
                        Image(systemName: "pills.fill")
                            .font(.title3)
                            .foregroundStyle(medication.color)
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text(medication.name + " " + medication.dose)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(DemoTheme.ink)
                    Text(medication.schedule)
                        .font(.subheadline)
                        .foregroundStyle(DemoTheme.secondary)
                    Text(medication.purpose)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(medication.color)
                }

                Spacer()
            }

            HStack(spacing: 12) {
                MiniFact(title: "When", value: medication.timing)
                MiniFact(title: "Dose tracker", value: "\(store.dosesLogged(for: medication))/\(store.doseTarget(for: medication)) logged")
            }

            Text(medication.patientExplanation)
                .font(.subheadline)
                .foregroundStyle(DemoTheme.secondary)
        }
        .surfaceCard()
    }
}

private struct TodaySummaryStrip: View {
    @ObservedObject var store: PatientDemoStore
    let onOpenProof: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader("Daily progress", subtitle: "See what’s done, what’s overdue, and what comes next.")
            HStack(spacing: 12) {
                SummaryMetric(title: "Completed", value: "\(store.takenTaskCount)", tint: DemoTheme.mint)
                SummaryMetric(title: "Due now", value: "\(store.dueTaskCount)", tint: DemoTheme.amber)
                SummaryMetric(title: "Missed", value: "\(store.missedTaskCount)", tint: DemoTheme.coral)
            }

            if let nextTask = store.nextPriorityTask {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Next dose")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DemoTheme.secondary)
                    Text("\(nextTask.medicationName) • \(nextTask.time)")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(DemoTheme.ink)
                    Text(nextTask.context)
                        .font(.subheadline)
                        .foregroundStyle(DemoTheme.secondary)

                    HStack(spacing: 10) {
                        Button {
                            store.setStatus(for: nextTask, to: .taken)
                        } label: {
                            Text("Log now")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(DemoTheme.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .buttonStyle(.plain)

                        Button(action: onOpenProof) {
                            Text("Use proof")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(DemoTheme.violet)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(DemoTheme.violet.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(18)
                .background(Color(hex: "F5F8FE"))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
        }
        .surfaceCard()
    }
}

private struct SummaryMetric: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(DemoTheme.secondary)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(tint.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct TodayTaskCard: View {
    let task: MedicationTask
    @ObservedObject var store: PatientDemoStore
    let onOpenProof: () -> Void

    private var taskStatus: TaskStatus { store.status(for: task) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                Circle()
                    .fill(taskStatus.color.opacity(0.15))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: iconName)
                            .foregroundStyle(taskStatus.color)
                    }

                VStack(alignment: .leading, spacing: 5) {
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

            if let medication = store.medication(for: task) {
                Text(medication.whyItMatters)
                    .font(.subheadline)
                    .foregroundStyle(DemoTheme.secondary)
                    .padding(14)
                    .background(Color(hex: "F7F9FE"))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            HStack(spacing: 10) {
                TaskActionButton(title: "Taken", tint: DemoTheme.mint, isSelected: taskStatus == .taken) {
                    store.setStatus(for: task, to: .taken)
                }
                TaskActionButton(title: "Snooze", tint: DemoTheme.amber, isSelected: false) {
                    store.snooze(task)
                }
                TaskActionButton(title: "Skip", tint: DemoTheme.coral, isSelected: taskStatus == .missed) {
                    store.setStatus(for: task, to: .missed)
                }
            }

            Button(action: onOpenProof) {
                HStack(spacing: 10) {
                    Image(systemName: "camera.fill")
                    Text("Quick proof of dose")
                    Spacer()
                    Image(systemName: "arrow.up.right.circle.fill")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DemoTheme.violet)
                .padding(14)
                .background(DemoTheme.violet.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .surfaceCard()
    }

    private var iconName: String {
        switch taskStatus {
        case .taken:
            return "checkmark.circle.fill"
        case .due:
            return "bell.badge.fill"
        case .missed:
            return "exclamationmark.circle.fill"
        }
    }
}

private struct InteractiveQuickTile: View {
    let title: String
    let value: String
    let subtitle: String
    let tint: Color
    let icon: String

    var body: some View {
        MetricTile(title: title, value: value, subtitle: subtitle, tint: tint, icon: icon)
    }
}

private struct SelectedDayCard: View {
    let day: DailyAdherence

    private var detail: String {
        switch day.status {
        case .complete:
            return "All scheduled doses were completed on this day."
        case .partial:
            return "At least one scheduled dose was missed or delayed."
        case .missed:
            return "This day contributes directly to rising risk and broken streaks."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Day \(day.day)")
                    .font(.headline)
                    .foregroundStyle(DemoTheme.ink)
                Spacer()
                StatusChip(title: day.status.rawValue.capitalized, color: day.status.color, icon: day.status.icon)
            }
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(DemoTheme.secondary)
        }
        .surfaceCard()
    }
}

private struct ToggleCard: View {
    let title: String
    let subtitle: String
    let isOn: Bool
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(DemoTheme.ink)
                Text(isOn ? "Active" : "Pending")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(tint)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(DemoTheme.secondary)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tint.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct DoseTrackerCard: View {
    @ObservedObject var store: PatientDemoStore
    let medication: Medication

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader("Today’s dose tracker", subtitle: "A local-only interaction to show how dose logging could feel.")
            HStack(spacing: 14) {
                Button {
                    store.decrementDose(for: medication)
                } label: {
                    DoseStepButton(icon: "minus")
                }

                VStack(spacing: 4) {
                    Text("\(store.dosesLogged(for: medication))/\(store.doseTarget(for: medication))")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(DemoTheme.ink)
                    Text("doses logged today")
                        .font(.caption)
                        .foregroundStyle(DemoTheme.secondary)
                }
                .frame(maxWidth: .infinity)

                Button {
                    store.incrementDose(for: medication)
                } label: {
                    DoseStepButton(icon: "plus")
                }
            }

            HStack(spacing: 10) {
                if store.proofMedicationName == medication.name && store.proofStage == .verified {
                    StatusChip(title: "Photo-verified", color: DemoTheme.violet, icon: "camera.aperture")
                }
                if store.dosesLogged(for: medication) == store.doseTarget(for: medication) {
                    StatusChip(title: "Goal met", color: DemoTheme.mint, icon: "checkmark.seal.fill")
                } else {
                    StatusChip(title: "Still due", color: DemoTheme.amber, icon: "bell.fill")
                }
            }
        }
        .surfaceCard()
    }
}

private struct DoseStepButton: View {
    let icon: String

    var body: some View {
        Circle()
            .fill(Color(hex: "EEF3FF"))
            .frame(width: 52, height: 52)
            .overlay {
                Image(systemName: icon)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(DemoTheme.blue)
            }
    }
}

private struct MiniFact: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(DemoTheme.secondary)
            Text(value)
                .font(.caption)
                .foregroundStyle(DemoTheme.ink)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(hex: "F5F8FE"))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct InfoPanel: View {
    let title: String
    let message: String
    let tint: Color

    var bodyView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Circle()
                    .fill(tint.opacity(0.14))
                    .frame(width: 34, height: 34)
                    .overlay {
                        Circle()
                            .fill(tint)
                            .frame(width: 12, height: 12)
                    }
                Text(title)
                    .font(.headline)
                    .foregroundStyle(DemoTheme.ink)
            }
            Text(message)
                .font(.subheadline)
                .foregroundStyle(DemoTheme.secondary)
        }
        .surfaceCard()
    }

    var body: some View { bodyView }
}

private struct RichInfoTile: View {
    let title: String
    let value: String
    let subtitle: String
    let tint: Color
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(DemoTheme.secondary)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(DemoTheme.ink)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(DemoTheme.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        ConditionsMedicationsView(store: PatientDemoStore(patient: DemoData.ayo))
    }
}
