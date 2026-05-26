import SwiftUI
import Combine

enum DemoRole: String, CaseIterable, Identifiable {
    case patient
    case clinician
    case medicalAid

    var id: String { rawValue }

    var title: String {
        switch self {
        case .patient: return "Patient App"
        case .clinician: return "Clinician Dashboard"
        case .medicalAid: return "Medical Aid Analytics"
        }
    }

    var subtitle: String {
        switch self {
        case .patient:
            return "Conditions, medications, adherence, AI coach, and follow-up plan."
        case .clinician:
            return "Diagnosis, prescribing, adherence review, and non-adherence insight."
        case .medicalAid:
            return "Population risk, avoidable spend, outreach, and predictive care signals."
        }
    }

    var icon: String {
        switch self {
        case .patient: return "heart.text.square.fill"
        case .clinician: return "stethoscope"
        case .medicalAid: return "chart.line.text.clipboard"
        }
    }
}

struct PatientProfile: Identifiable, Hashable {
    let id: UUID
    let name: String
    let age: Int
    let avatar: String
    let heroTitle: String
    let heroSubtitle: String
    let adherenceScore: Int
    let careScore: Int
    let engagementScore: Int
    let streak: Int
    let riskLevel: RiskLevel
    let followUpDate: String
    let scriptRenewalDate: String
    let coachInsight: String
    let riskBanner: String
    let conditions: [Condition]
    let medications: [Medication]
    let todayTasks: [MedicationTask]
    let adherenceDays: [DailyAdherence]
    let nudges: [CoachNudge]
    let timeline: [TimelineEvent]
    let trend: [TrendPoint]
    let barrierNotes: [BarrierNote]
}

struct Condition: Identifiable, Hashable {
    let id: UUID
    let name: String
    let subtitle: String
    let icon: String
    let summary: String
    let careNote: String
}

struct Medication: Identifiable, Hashable {
    let id: UUID
    let name: String
    let dose: String
    let schedule: String
    let timing: String
    let purpose: String
    let howToTake: String
    let whyItMatters: String
    let patientExplanation: String
    let color: Color
}

struct MedicationTask: Identifiable, Hashable {
    let id: UUID
    let medicationName: String
    let time: String
    let context: String
    let status: TaskStatus
    let note: String
}

enum TaskStatus: String, Hashable {
    case taken
    case due
    case missed

    var color: Color {
        switch self {
        case .taken: return Color(hex: "31D27C")
        case .due: return Color(hex: "FFB648")
        case .missed: return Color(hex: "FF6B63")
        }
    }

    var label: String {
        switch self {
        case .taken: return "Taken"
        case .due: return "Due"
        case .missed: return "Missed"
        }
    }
}

struct DailyAdherence: Identifiable, Hashable {
    let id: UUID
    let day: Int
    let status: AdherenceStatus
}

enum AdherenceStatus: String, CaseIterable, Hashable {
    case complete
    case partial
    case missed

    var color: Color {
        switch self {
        case .complete: return Color(hex: "31D27C")
        case .partial: return Color(hex: "FFB648")
        case .missed: return Color(hex: "FF6B63")
        }
    }

    var icon: String {
        switch self {
        case .complete: return "checkmark"
        case .partial: return "minus"
        case .missed: return "xmark"
        }
    }
}

struct CoachNudge: Identifiable, Hashable {
    let id: UUID
    let title: String
    let body: String
    let tone: NudgeTone
}

enum NudgeTone: Hashable {
    case alert
    case support
    case coach

    var color: Color {
        switch self {
        case .alert: return Color(hex: "FF7A59")
        case .support: return Color(hex: "2F6BFF")
        case .coach: return Color(hex: "7A63FF")
        }
    }

    var icon: String {
        switch self {
        case .alert: return "exclamationmark.triangle.fill"
        case .support: return "heart.text.square.fill"
        case .coach: return "sparkles"
        }
    }
}

struct TimelineEvent: Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let dateLabel: String
    let status: TimelineStatus
}

enum TimelineStatus: Hashable {
    case complete
    case current
    case upcoming
    case warning

    var color: Color {
        switch self {
        case .complete: return Color(hex: "31D27C")
        case .current: return Color(hex: "2F6BFF")
        case .upcoming: return Color(hex: "7A63FF")
        case .warning: return Color(hex: "FF7A59")
        }
    }
}

struct TrendPoint: Identifiable, Hashable {
    let id: UUID
    let label: String
    let value: Int
}

struct BarrierNote: Identifiable, Hashable {
    let id: UUID
    let title: String
    let body: String
    let severity: RiskLevel
}

enum RiskLevel: String, Hashable {
    case stable
    case rising
    case high
    case critical

    var color: Color {
        switch self {
        case .stable: return Color(hex: "31D27C")
        case .rising: return Color(hex: "FFB648")
        case .high: return Color(hex: "FF7A59")
        case .critical: return Color(hex: "FF4D5E")
        }
    }

    var label: String {
        rawValue.capitalized
    }
}

struct ClinicianSnapshot: Hashable {
    let clinicianName: String
    let specialty: String
    let patientSummary: String
    let diagnoses: [DiagnosisRecord]
    let prescriptions: [PrescriptionDraft]
    let reviewSignals: [ReviewSignal]
    let assessment: String
    let recommendation: String
}

struct ClinicianCase: Identifiable, Hashable {
    let id: UUID
    let patient: PatientProfile
    let snapshot: ClinicianSnapshot
    let queueLabel: String
}

struct DiagnosisRecord: Identifiable, Hashable {
    let id: UUID
    let name: String
    let note: String
}

struct PrescriptionDraft: Identifiable, Hashable {
    let id: UUID
    let medicationName: String
    let dosage: String
    let frequency: String
    let scriptDuration: String
    let followUpDate: String
}

struct ReviewSignal: Identifiable, Hashable {
    let id: UUID
    let title: String
    let detail: String
    let severity: RiskLevel
}

struct AnalyticsSnapshot: Hashable {
    let coveredLives: Int
    let stableMembers: Int
    let risingMembers: Int
    let highMembers: Int
    let criticalMembers: Int
    let projectedSavings: String
    let avoidableSpend: String
    let outreachQueueCount: Int
    let renewalRiskCount: Int
    let distribution: [DistributionPoint]
    let trends: [TrendPoint]
    let outreachQueue: [OutreachMember]
    let insights: [PopulationInsight]
    let predictiveInputs: [PredictiveNode]
    let predictiveOutputs: [PredictiveNode]
}

struct DistributionPoint: Identifiable, Hashable {
    let id: UUID
    let label: String
    let value: Int
    let color: Color
}

struct OutreachMember: Identifiable, Hashable {
    let id: UUID
    let name: String
    let condition: String
    let riskLevel: RiskLevel
    let adherenceScore: Int
    let refillRisk: String
    let opportunity: String
}

struct PopulationInsight: Identifiable, Hashable {
    let id: UUID
    let title: String
    let detail: String
    let icon: String
}

struct PredictiveNode: Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let color: Color
}

enum ProofCaptureStage: String {
    case ready
    case framing
    case captured
    case verified
}

final class PatientDemoStore: ObservableObject {
    let patient: PatientProfile

    @Published private(set) var taskStatuses: [UUID: TaskStatus]
    @Published private(set) var loggedDoseCounts: [UUID: Int]
    @Published var acknowledgedNudgeIDs: Set<UUID>
    @Published var selectedAdherenceDay: Int
    @Published var renewalReminderEnabled: Bool
    @Published var followUpConfirmed: Bool
    @Published var snoozedTasks: [UUID: String]
    @Published var proofStage: ProofCaptureStage
    @Published var proofMedicationName: String
    @Published var proofUsingFrontCamera: Bool
    @Published var proofTaskID: UUID?

    init(patient: PatientProfile) {
        self.patient = patient
        self.taskStatuses = Dictionary(uniqueKeysWithValues: patient.todayTasks.map { ($0.id, $0.status) })
        self.loggedDoseCounts = Dictionary(
            uniqueKeysWithValues: patient.medications.map { medication in
                let takenCount = patient.todayTasks.filter { $0.medicationName == medication.name && $0.status == .taken }.count
                return (medication.id, takenCount)
            }
        )
        self.acknowledgedNudgeIDs = []
        self.selectedAdherenceDay = patient.adherenceDays.last?.day ?? 1
        self.renewalReminderEnabled = true
        self.followUpConfirmed = false
        self.snoozedTasks = [:]
        self.proofStage = .ready
        self.proofMedicationName = patient.todayTasks.first(where: { $0.status != .taken })?.medicationName ?? patient.medications.first?.name ?? ""
        self.proofUsingFrontCamera = false
        self.proofTaskID = nil
    }

    func status(for task: MedicationTask) -> TaskStatus {
        taskStatuses[task.id] ?? task.status
    }

    func setStatus(for task: MedicationTask, to newStatus: TaskStatus) {
        let previousStatus = status(for: task)
        taskStatuses[task.id] = newStatus
        snoozedTasks.removeValue(forKey: task.id)

        guard let medication = patient.medications.first(where: { $0.name == task.medicationName }) else {
            return
        }

        let currentCount = loggedDoseCounts[medication.id] ?? 0
        if previousStatus != .taken, newStatus == .taken {
            loggedDoseCounts[medication.id] = min(doseTarget(for: medication), currentCount + 1)
        } else if previousStatus == .taken, newStatus != .taken {
            loggedDoseCounts[medication.id] = max(0, currentCount - 1)
        }
    }

    func note(for task: MedicationTask) -> String {
        if let snoozeLabel = snoozedTasks[task.id], status(for: task) == .due {
            return "Reminder \(snoozeLabel)"
        }
        switch status(for: task) {
        case .taken:
            return proofStage == .verified && task.medicationName == proofMedicationName ? "Dose verified" : "Dose logged"
        case .due:
            return "Reminder queued"
        case .missed:
            return "Needs attention"
        }
    }

    func doseTarget(for medication: Medication) -> Int {
        max(1, patient.todayTasks.filter { $0.medicationName == medication.name }.count)
    }

    func dosesLogged(for medication: Medication) -> Int {
        loggedDoseCounts[medication.id] ?? 0
    }

    func setDoseCount(for medication: Medication, to newValue: Int) {
        loggedDoseCounts[medication.id] = min(max(newValue, 0), doseTarget(for: medication))
    }

    func incrementDose(for medication: Medication) {
        setDoseCount(for: medication, to: dosesLogged(for: medication) + 1)
    }

    func decrementDose(for medication: Medication) {
        setDoseCount(for: medication, to: dosesLogged(for: medication) - 1)
    }

    func selectAdherenceDay(_ day: Int) {
        selectedAdherenceDay = day
    }

    var selectedAdherenceEntry: DailyAdherence? {
        patient.adherenceDays.first(where: { $0.day == selectedAdherenceDay })
    }

    func acknowledge(_ nudge: CoachNudge) {
        acknowledgedNudgeIDs.insert(nudge.id)
    }

    func isAcknowledged(_ nudge: CoachNudge) -> Bool {
        acknowledgedNudgeIDs.contains(nudge.id)
    }

    func openProofCamera() {
        if proofTaskID == nil {
            proofTaskID = patient.todayTasks.first(where: { $0.medicationName == proofMedicationName && status(for: $0) != .taken })?.id
        }
        proofStage = .framing
    }

    func openProofCamera(for task: MedicationTask) {
        proofMedicationName = task.medicationName
        proofTaskID = task.id
        proofStage = .framing
    }

    func captureProof() {
        proofStage = .captured
    }

    func verifyProof() {
        proofStage = .verified
        if let targetTaskID = proofTaskID,
           let task = patient.todayTasks.first(where: { $0.id == targetTaskID }) {
            setStatus(for: task, to: .taken)
        } else if let task = patient.todayTasks.first(where: { $0.medicationName == proofMedicationName && status(for: $0) != .taken }) {
            setStatus(for: task, to: .taken)
        }
    }

    func resetProof() {
        proofStage = .ready
        proofTaskID = nil
    }

    var openNudgesCount: Int {
        patient.nudges.filter { !acknowledgedNudgeIDs.contains($0.id) }.count
    }

    func snooze(_ task: MedicationTask, by label: String = "in 15 min") {
        taskStatuses[task.id] = .due
        snoozedTasks[task.id] = label
    }

    func medication(for task: MedicationTask) -> Medication? {
        patient.medications.first(where: { $0.name == task.medicationName })
    }

    func reasonForTask(_ task: MedicationTask) -> String {
        medication(for: task)?.whyItMatters ?? "Supports your care plan."
    }

    var todayProgressText: String {
        "\(takenTaskCount) of \(patient.todayTasks.count) doses completed"
    }

    var takenTaskCount: Int {
        patient.todayTasks.filter { status(for: $0) == .taken }.count
    }

    var dueTaskCount: Int {
        patient.todayTasks.filter { status(for: $0) == .due }.count
    }

    var missedTaskCount: Int {
        patient.todayTasks.filter { status(for: $0) == .missed }.count
    }

    var nextPriorityTask: MedicationTask? {
        patient.todayTasks.first(where: { status(for: $0) == .due }) ??
        patient.todayTasks.first(where: { status(for: $0) == .missed })
    }

    var groupedTasks: [(title: String, tasks: [MedicationTask])] {
        let grouped = Dictionary(grouping: patient.todayTasks, by: taskGroupTitle(for:))
        let order = ["Morning", "Midday", "Evening", "Tonight"]
        return order.compactMap { key in
            guard let tasks = grouped[key] else { return nil }
            return (key, tasks.sorted { $0.time < $1.time })
        }
    }

    func taskGroupTitle(for task: MedicationTask) -> String {
        let hour = Int(task.time.prefix(2)) ?? 12
        switch hour {
        case ..<11:
            return "Morning"
        case 11..<15:
            return "Midday"
        case 15..<19:
            return "Evening"
        default:
            return "Tonight"
        }
    }
}
