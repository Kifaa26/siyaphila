import SwiftUI

enum DemoData {
    static let ayo = PatientProfile(
        id: UUID(uuidString: "22222222-2222-2222-2222-222222222222") ?? UUID(),
        name: "Ayo Naidoo",
        age: 54,
        avatar: "person.crop.circle.badge.exclamationmark.fill",
        heroTitle: "Risk is rising, but still reversible.",
        heroSubtitle: "Ayo is one month into use with poor adherence, broken streaks, and visible evening-dose drift.",
        adherenceScore: 46,
        careScore: 54,
        engagementScore: 49,
        streak: 2,
        riskLevel: .high,
        followUpDate: "27 Apr",
        scriptRenewalDate: "24 Apr",
        coachInsight: "Evening doses and weekends are the main drop-off points. Early refill prompts and earlier nudges could recover adherence fastest.",
        riskBanner: "Risk rising • follow-up due soon",
        conditions: [
            Condition(
                id: UUID(),
                name: "Type 2 Diabetes",
                subtitle: "HbA1c above target",
                icon: "drop.fill",
                summary: "Daily diabetes medication helps reduce long-term complications like kidney disease, vision loss, nerve damage, heart attack, and stroke.",
                careNote: "Poor control may reflect missed medication rather than treatment failure."
            ),
            Condition(
                id: UUID(),
                name: "Hypertension",
                subtitle: "Needs tighter control",
                icon: "heart.fill",
                summary: "Blood pressure medication works quietly in the background and lowers long-term risk even when the patient feels fine.",
                careNote: "Repeated missed morning doses reduce day-to-day protection."
            ),
            Condition(
                id: UUID(),
                name: "Dyslipidaemia",
                subtitle: "Cardiovascular risk reduction",
                icon: "waveform.path.ecg",
                summary: "Cholesterol treatment lowers future cardiovascular risk, especially alongside diabetes and hypertension treatment.",
                careNote: "Evening dose behavior is currently the weakest adherence pattern."
            )
        ],
        medications: [
            Medication(
                id: UUID(),
                name: "Metformin",
                dose: "1 g",
                schedule: "Twice daily with meals",
                timing: "08:00 and 18:00",
                purpose: "Glucose control",
                howToTake: "Take with breakfast and dinner to reduce stomach upset.",
                whyItMatters: "Consistent use improves glucose control and lowers long-term complication risk.",
                patientExplanation: "This is your diabetes medication. Even when you feel well, it helps protect your kidneys, nerves, heart, and eyes over time.",
                color: Color(hex: "2F6BFF")
            ),
            Medication(
                id: UUID(),
                name: "Amlodipine",
                dose: "5 mg",
                schedule: "Every morning",
                timing: "08:00",
                purpose: "Blood pressure control",
                howToTake: "Take every morning as part of your regular routine.",
                whyItMatters: "Blood pressure medication lowers future stroke, heart failure, and kidney risk.",
                patientExplanation: "This medication protects you even when you do not feel symptoms. Missing it can let silent damage build over time.",
                color: Color(hex: "FF6B63")
            ),
            Medication(
                id: UUID(),
                name: "Atorvastatin",
                dose: "20 mg",
                schedule: "Every evening",
                timing: "20:00",
                purpose: "Cholesterol lowering",
                howToTake: "Take in the evening, ideally linked to a consistent routine.",
                whyItMatters: "Lowers long-term cardiovascular risk in diabetes and hypertension.",
                patientExplanation: "This is your cholesterol medication. It helps reduce the risk of future heart attack or stroke, even if you cannot feel it working.",
                color: Color(hex: "F5B43C")
            )
        ],
        todayTasks: [
            MedicationTask(id: UUID(), medicationName: "Metformin", time: "08:00", context: "With breakfast", status: .taken, note: "Morning dose logged"),
            MedicationTask(id: UUID(), medicationName: "Amlodipine", time: "08:00", context: "Morning routine", status: .missed, note: "Missed this morning"),
            MedicationTask(id: UUID(), medicationName: "Metformin", time: "18:00", context: "With dinner", status: .due, note: "Reminder queued"),
            MedicationTask(id: UUID(), medicationName: "Atorvastatin", time: "20:00", context: "Evening routine", status: .due, note: "Tonight due")
        ],
        adherenceDays: [
            .init(id: UUID(), day: 1, status: .complete), .init(id: UUID(), day: 2, status: .missed), .init(id: UUID(), day: 3, status: .partial), .init(id: UUID(), day: 4, status: .complete), .init(id: UUID(), day: 5, status: .missed), .init(id: UUID(), day: 6, status: .partial), .init(id: UUID(), day: 7, status: .complete),
            .init(id: UUID(), day: 8, status: .missed), .init(id: UUID(), day: 9, status: .missed), .init(id: UUID(), day: 10, status: .partial), .init(id: UUID(), day: 11, status: .complete), .init(id: UUID(), day: 12, status: .missed), .init(id: UUID(), day: 13, status: .partial), .init(id: UUID(), day: 14, status: .complete),
            .init(id: UUID(), day: 15, status: .missed), .init(id: UUID(), day: 16, status: .complete), .init(id: UUID(), day: 17, status: .partial), .init(id: UUID(), day: 18, status: .missed), .init(id: UUID(), day: 19, status: .complete), .init(id: UUID(), day: 20, status: .missed), .init(id: UUID(), day: 21, status: .partial),
            .init(id: UUID(), day: 22, status: .complete), .init(id: UUID(), day: 23, status: .missed), .init(id: UUID(), day: 24, status: .missed), .init(id: UUID(), day: 25, status: .partial), .init(id: UUID(), day: 26, status: .complete), .init(id: UUID(), day: 27, status: .missed), .init(id: UUID(), day: 28, status: .partial),
            .init(id: UUID(), day: 29, status: .missed), .init(id: UUID(), day: 30, status: .complete)
        ],
        nudges: [
            CoachNudge(id: UUID(), title: "You missed 2 evening doses this week.", body: "Take tonight’s medication to restart your streak and protect your heart risk plan.", tone: .alert),
            CoachNudge(id: UUID(), title: "Your adherence has dropped this month.", body: "The biggest pattern is on weekends and evenings. Linking doses to dinner may help.", tone: .coach),
            CoachNudge(id: UUID(), title: "Your follow-up may be due soon.", body: "Your clinician review is coming up. Logging this week consistently helps make that visit more useful.", tone: .support),
            CoachNudge(id: UUID(), title: "Script renewal is almost due.", body: "Renew now to avoid another gap in blood pressure and cholesterol treatment.", tone: .alert)
        ],
        timeline: [
            TimelineEvent(id: UUID(), title: "Month 1 started", subtitle: "Care plan and reminders activated", dateLabel: "24 Mar", status: .complete),
            TimelineEvent(id: UUID(), title: "Adherence drift detected", subtitle: "Weekend and evening misses increased", dateLabel: "08 Apr", status: .warning),
            TimelineEvent(id: UUID(), title: "Script renewal due", subtitle: "Atorvastatin and Amlodipine renewal approaching", dateLabel: "24 Apr", status: .current),
            TimelineEvent(id: UUID(), title: "Doctor follow-up", subtitle: "Review disease control versus non-adherence", dateLabel: "27 Apr", status: .upcoming)
        ],
        trend: [
            TrendPoint(id: UUID(), label: "Week 1", value: 56),
            TrendPoint(id: UUID(), label: "Week 2", value: 38),
            TrendPoint(id: UUID(), label: "Week 3", value: 44),
            TrendPoint(id: UUID(), label: "Week 4", value: 50)
        ],
        barrierNotes: [
            BarrierNote(id: UUID(), title: "Evening-dose drift", body: "Repeated misses happen after work and on weekends.", severity: .high),
            BarrierNote(id: UUID(), title: "Regimen burden", body: "Three medications across morning and evening windows increases complexity.", severity: .rising),
            BarrierNote(id: UUID(), title: "Poor control may reflect non-adherence", body: "Before escalating medication, review whether current disease control is driven by missed doses.", severity: .high)
        ]
    )

    static let clinician = ClinicianSnapshot(
        clinicianName: "Dr N. Govender",
        specialty: "Chronic disease clinic",
        patientSummary: "Ayo Naidoo presents with Type 2 Diabetes, Hypertension, and Dyslipidaemia. One month of app data suggests disease control may be compromised by non-adherence rather than medication failure.",
        diagnoses: [
            DiagnosisRecord(id: UUID(), name: "Type 2 Diabetes", note: "HbA1c above target"),
            DiagnosisRecord(id: UUID(), name: "Hypertension", note: "Blood pressure not yet controlled"),
            DiagnosisRecord(id: UUID(), name: "Dyslipidaemia", note: "Statin remains indicated")
        ],
        prescriptions: [
            PrescriptionDraft(id: UUID(), medicationName: "Metformin", dosage: "1 g", frequency: "Twice daily with meals", scriptDuration: "30 days", followUpDate: "27 Apr"),
            PrescriptionDraft(id: UUID(), medicationName: "Amlodipine", dosage: "5 mg", frequency: "Every morning", scriptDuration: "30 days", followUpDate: "27 Apr"),
            PrescriptionDraft(id: UUID(), medicationName: "Atorvastatin", dosage: "20 mg", frequency: "Every evening", scriptDuration: "30 days", followUpDate: "27 Apr")
        ],
        reviewSignals: [
            ReviewSignal(id: UUID(), title: "Missed-dose pattern", detail: "Misses cluster on weekends and evening doses.", severity: .high),
            ReviewSignal(id: UUID(), title: "Renewal risk", detail: "Script renewal is due within days and may worsen gaps if delayed.", severity: .rising),
            ReviewSignal(id: UUID(), title: "Follow-up priority", detail: "Useful moment to review adherence barriers before intensifying medication.", severity: .high)
        ],
        assessment: "Current app signals suggest that poor control may be at least partly driven by inconsistent medication behavior across all three conditions.",
        recommendation: "Review barriers, reinforce regimen purpose, renew scripts, and reassess control after adherence recovery before labeling the regimen ineffective."
    )

    static let lerato = PatientProfile(
        id: UUID(uuidString: "33333333-3333-3333-3333-333333333333") ?? UUID(),
        name: "Lerato Mthembu",
        age: 61,
        avatar: "person.crop.circle.fill",
        heroTitle: "Blood pressure is drifting upward.",
        heroSubtitle: "Moderate adherence with script renewal friction and recent morning misses.",
        adherenceScore: 68,
        careScore: 63,
        engagementScore: 57,
        streak: 4,
        riskLevel: .rising,
        followUpDate: "29 Apr",
        scriptRenewalDate: "26 Apr",
        coachInsight: "Most missed doses happen around early morning travel and refill timing.",
        riskBanner: "Rising risk • renewal support needed",
        conditions: [
            Condition(id: UUID(), name: "Hypertension", subtitle: "Above target", icon: "heart.fill", summary: "Blood pressure control still needs better daily consistency.", careNote: "Morning misses appear to be the main driver."),
            Condition(id: UUID(), name: "Type 2 Diabetes", subtitle: "Borderline control", icon: "drop.fill", summary: "Glucose control is acceptable but vulnerable to further drift.", careNote: "Do not intensify before checking adherence pattern.")
        ],
        medications: [
            Medication(id: UUID(), name: "Amlodipine", dose: "10 mg", schedule: "Every morning", timing: "07:00", purpose: "Blood pressure control", howToTake: "Take at the same time each morning.", whyItMatters: "Supports steady blood pressure control and stroke prevention.", patientExplanation: "A daily blood pressure protector that works best with a stable morning routine.", color: Color(hex: "FF6B63")),
            Medication(id: UUID(), name: "Metformin", dose: "500 mg", schedule: "Twice daily with meals", timing: "07:00 and 18:00", purpose: "Glucose control", howToTake: "Take with breakfast and supper.", whyItMatters: "Helps maintain glucose control over time.", patientExplanation: "This helps keep sugar levels from drifting upward.", color: Color(hex: "2F6BFF"))
        ],
        todayTasks: [
            MedicationTask(id: UUID(), medicationName: "Amlodipine", time: "07:00", context: "Morning routine", status: .missed, note: "Missed on travel day"),
            MedicationTask(id: UUID(), medicationName: "Metformin", time: "18:00", context: "With supper", status: .due, note: "Reminder queued")
        ],
        adherenceDays: makeAdherencePattern([.complete, .complete, .partial, .missed, .complete, .partial, .complete, .complete, .missed, .partial, .complete, .complete, .partial, .complete, .missed, .complete, .partial, .complete, .complete, .missed, .complete, .partial, .complete, .complete, .partial, .missed, .complete, .complete, .partial, .complete]),
        nudges: [
            CoachNudge(id: UUID(), title: "Renew before Friday", body: "Renewing before the weekend avoids another blood pressure treatment gap.", tone: .alert)
        ],
        timeline: [
            TimelineEvent(id: UUID(), title: "Renewal support triggered", subtitle: "Medication renewal reminder sent", dateLabel: "22 Apr", status: .current),
            TimelineEvent(id: UUID(), title: "Follow-up booked", subtitle: "BP review and adherence discussion", dateLabel: "29 Apr", status: .upcoming)
        ],
        trend: [TrendPoint(id: UUID(), label: "Week 1", value: 74), TrendPoint(id: UUID(), label: "Week 2", value: 70), TrendPoint(id: UUID(), label: "Week 3", value: 63), TrendPoint(id: UUID(), label: "Week 4", value: 68)],
        barrierNotes: [
            BarrierNote(id: UUID(), title: "Travel routine disruption", body: "Morning commute appears to interrupt medication behavior.", severity: .rising)
        ]
    )

    static let sibusiso = PatientProfile(
        id: UUID(uuidString: "44444444-4444-4444-4444-444444444444") ?? UUID(),
        name: "Sibusiso Daniels",
        age: 47,
        avatar: "person.crop.circle.fill",
        heroTitle: "Heart failure follow-up needs attention.",
        heroSubtitle: "Low adherence with repeat refill gap and high outreach priority.",
        adherenceScore: 41,
        careScore: 48,
        engagementScore: 40,
        streak: 1,
        riskLevel: .critical,
        followUpDate: "23 Apr",
        scriptRenewalDate: "22 Apr",
        coachInsight: "Refill gaps and low engagement are the strongest signals.",
        riskBanner: "Critical risk • urgent review",
        conditions: [
            Condition(id: UUID(), name: "Heart Failure", subtitle: "Needs close review", icon: "heart.circle.fill", summary: "Recent medication inconsistency may increase decompensation risk.", careNote: "Adherence must be reviewed urgently."),
            Condition(id: UUID(), name: "Hypertension", subtitle: "Secondary concern", icon: "heart.fill", summary: "BP treatment is also inconsistent.", careNote: "Overlap with cardiac regimen complexity.")
        ],
        medications: [
            Medication(id: UUID(), name: "Furosemide", dose: "40 mg", schedule: "Every morning", timing: "07:00", purpose: "Fluid management", howToTake: "Take in the morning to reduce nighttime disruption.", whyItMatters: "Prevents fluid build-up and symptom worsening.", patientExplanation: "Helps your body clear excess fluid and supports your breathing.", color: Color(hex: "35C98A")),
            Medication(id: UUID(), name: "Bisoprolol", dose: "5 mg", schedule: "Every morning", timing: "07:00", purpose: "Cardiac protection", howToTake: "Take daily at the same time.", whyItMatters: "Supports heart function and stability.", patientExplanation: "Helps protect the heart from working too hard.", color: Color(hex: "7A63FF"))
        ],
        todayTasks: [
            MedicationTask(id: UUID(), medicationName: "Furosemide", time: "07:00", context: "Morning", status: .missed, note: "Not logged"),
            MedicationTask(id: UUID(), medicationName: "Bisoprolol", time: "07:00", context: "Morning", status: .missed, note: "Not logged")
        ],
        adherenceDays: makeAdherencePattern([.missed, .partial, .complete, .missed, .missed, .partial, .complete, .missed, .missed, .partial, .complete, .missed, .missed, .partial, .complete, .missed, .missed, .partial, .complete, .missed, .missed, .partial, .complete, .missed, .missed, .partial, .complete, .missed, .missed, .partial]),
        nudges: [],
        timeline: [
            TimelineEvent(id: UUID(), title: "Refill gap flagged", subtitle: "No renewal logged", dateLabel: "20 Apr", status: .warning),
            TimelineEvent(id: UUID(), title: "Urgent clinician review", subtitle: "Discuss adherence and symptoms", dateLabel: "23 Apr", status: .current)
        ],
        trend: [TrendPoint(id: UUID(), label: "Week 1", value: 48), TrendPoint(id: UUID(), label: "Week 2", value: 46), TrendPoint(id: UUID(), label: "Week 3", value: 39), TrendPoint(id: UUID(), label: "Week 4", value: 41)],
        barrierNotes: [
            BarrierNote(id: UUID(), title: "Low engagement", body: "The patient is not responding to standard reminder intensity.", severity: .critical)
        ]
    )

    static let naledi = PatientProfile(
        id: UUID(uuidString: "55555555-5555-5555-5555-555555555555") ?? UUID(),
        name: "Naledi Jacobs",
        age: 36,
        avatar: "person.crop.circle.fill",
        heroTitle: "Asthma control is mostly stable.",
        heroSubtitle: "Good controller adherence with isolated recent misses.",
        adherenceScore: 82,
        careScore: 79,
        engagementScore: 72,
        streak: 9,
        riskLevel: .stable,
        followUpDate: "06 May",
        scriptRenewalDate: "02 May",
        coachInsight: "Controller adherence is stable; refill timing remains the main watchpoint.",
        riskBanner: "Stable • maintenance support",
        conditions: [
            Condition(id: UUID(), name: "Asthma", subtitle: "Mostly controlled", icon: "lungs.fill", summary: "Controller use is generally consistent with low recent symptom risk.", careNote: "Maintain refill and inhaler technique support.")
        ],
        medications: [
            Medication(id: UUID(), name: "Budesonide/Formoterol", dose: "2 puffs", schedule: "Twice daily", timing: "07:00 and 19:00", purpose: "Controller inhaler", howToTake: "Use morning and evening every day.", whyItMatters: "Daily controller treatment reduces flare risk.", patientExplanation: "This inhaler keeps the lungs calmer over time.", color: Color(hex: "2F6BFF"))
        ],
        todayTasks: [
            MedicationTask(id: UUID(), medicationName: "Budesonide/Formoterol", time: "07:00", context: "Morning inhaler", status: .taken, note: "Logged")
        ],
        adherenceDays: makeAdherencePattern([.complete, .complete, .complete, .complete, .complete, .partial, .complete, .complete, .complete, .complete, .complete, .complete, .complete, .complete, .partial, .complete, .complete, .complete, .complete, .complete, .complete, .complete, .complete, .partial, .complete, .complete, .complete, .complete, .complete, .complete]),
        nudges: [],
        timeline: [
            TimelineEvent(id: UUID(), title: "Controller stable", subtitle: "Low immediate review priority", dateLabel: "21 Apr", status: .complete)
        ],
        trend: [TrendPoint(id: UUID(), label: "Week 1", value: 80), TrendPoint(id: UUID(), label: "Week 2", value: 84), TrendPoint(id: UUID(), label: "Week 3", value: 79), TrendPoint(id: UUID(), label: "Week 4", value: 82)],
        barrierNotes: [
            BarrierNote(id: UUID(), title: "Low current concern", body: "No major adherence barrier is currently visible.", severity: .stable)
        ]
    )

    static let clinicianCases: [ClinicianCase] = [
        ClinicianCase(
            id: ayo.id,
            patient: ayo,
            snapshot: clinician,
            queueLabel: "High priority"
        ),
        ClinicianCase(
            id: lerato.id,
            patient: lerato,
            snapshot: ClinicianSnapshot(
                clinicianName: "Dr N. Govender",
                specialty: "Chronic disease clinic",
                patientSummary: "Lerato Mthembu shows moderate chronic disease adherence with recent BP drift and script renewal friction.",
                diagnoses: [
                    DiagnosisRecord(id: UUID(), name: "Hypertension", note: "Recent morning misses"),
                    DiagnosisRecord(id: UUID(), name: "Type 2 Diabetes", note: "Borderline control")
                ],
                prescriptions: [
                    PrescriptionDraft(id: UUID(), medicationName: "Amlodipine", dosage: "10 mg", frequency: "Every morning", scriptDuration: "30 days", followUpDate: "29 Apr"),
                    PrescriptionDraft(id: UUID(), medicationName: "Metformin", dosage: "500 mg", frequency: "Twice daily", scriptDuration: "30 days", followUpDate: "29 Apr")
                ],
                reviewSignals: [
                    ReviewSignal(id: UUID(), title: "Morning adherence gap", detail: "Routine disruption is affecting blood pressure treatment.", severity: .rising),
                    ReviewSignal(id: UUID(), title: "Renewal friction", detail: "Medication renewal needs support before another gap opens.", severity: .rising)
                ],
                assessment: "Control drift may still be recoverable with adherence support and renewal intervention rather than medication escalation.",
                recommendation: "Stabilize the morning routine, renew scripts early, and reassess control after two weeks of improved adherence."
            ),
            queueLabel: "Renewal watch"
        ),
        ClinicianCase(
            id: sibusiso.id,
            patient: sibusiso,
            snapshot: ClinicianSnapshot(
                clinicianName: "Dr N. Govender",
                specialty: "Chronic disease clinic",
                patientSummary: "Sibusiso Daniels has heart failure with low engagement, refill gap risk, and urgent need for adherence review.",
                diagnoses: [
                    DiagnosisRecord(id: UUID(), name: "Heart Failure", note: "Urgent adherence risk"),
                    DiagnosisRecord(id: UUID(), name: "Hypertension", note: "Secondary regimen complexity")
                ],
                prescriptions: [
                    PrescriptionDraft(id: UUID(), medicationName: "Furosemide", dosage: "40 mg", frequency: "Every morning", scriptDuration: "30 days", followUpDate: "23 Apr"),
                    PrescriptionDraft(id: UUID(), medicationName: "Bisoprolol", dosage: "5 mg", frequency: "Every morning", scriptDuration: "30 days", followUpDate: "23 Apr")
                ],
                reviewSignals: [
                    ReviewSignal(id: UUID(), title: "Refill gap", detail: "No recent renewal recorded.", severity: .critical),
                    ReviewSignal(id: UUID(), title: "Low engagement", detail: "Standard reminder intensity is not working.", severity: .critical)
                ],
                assessment: "This case requires urgent review because deterioration risk may be adherence-driven and amplified by disengagement.",
                recommendation: "Escalate outreach, confirm symptoms, renew immediately, and schedule rapid clinician review."
            ),
            queueLabel: "Urgent review"
        ),
        ClinicianCase(
            id: naledi.id,
            patient: naledi,
            snapshot: ClinicianSnapshot(
                clinicianName: "Dr N. Govender",
                specialty: "Chronic disease clinic",
                patientSummary: "Naledi Jacobs shows largely stable asthma controller behavior with low immediate intervention need.",
                diagnoses: [
                    DiagnosisRecord(id: UUID(), name: "Asthma", note: "Mostly controlled")
                ],
                prescriptions: [
                    PrescriptionDraft(id: UUID(), medicationName: "Budesonide/Formoterol", dosage: "2 puffs", frequency: "Twice daily", scriptDuration: "60 days", followUpDate: "06 May")
                ],
                reviewSignals: [
                    ReviewSignal(id: UUID(), title: "Stable adherence", detail: "No major pattern of concern this month.", severity: .stable)
                ],
                assessment: "No evidence that poor control is currently being driven by adherence breakdown.",
                recommendation: "Maintain current regimen and reinforce refill timing."
            ),
            queueLabel: "Stable"
        )
    ]

    static let analytics = AnalyticsSnapshot(
        coveredLives: 1240,
        stableMembers: 702,
        risingMembers: 274,
        highMembers: 181,
        criticalMembers: 83,
        projectedSavings: "R 1.84M",
        avoidableSpend: "R 4.92M",
        outreachQueueCount: 126,
        renewalRiskCount: 74,
        distribution: [
            DistributionPoint(id: UUID(), label: "Stable", value: 702, color: RiskLevel.stable.color),
            DistributionPoint(id: UUID(), label: "Rising", value: 274, color: RiskLevel.rising.color),
            DistributionPoint(id: UUID(), label: "High", value: 181, color: RiskLevel.high.color),
            DistributionPoint(id: UUID(), label: "Critical", value: 83, color: RiskLevel.critical.color)
        ],
        trends: [
            TrendPoint(id: UUID(), label: "Jan", value: 61),
            TrendPoint(id: UUID(), label: "Feb", value: 58),
            TrendPoint(id: UUID(), label: "Mar", value: 54),
            TrendPoint(id: UUID(), label: "Apr", value: 49)
        ],
        outreachQueue: [
            OutreachMember(id: UUID(), name: "Ayo Naidoo", condition: "Diabetes • Hypertension • Dyslipidaemia", riskLevel: .high, adherenceScore: 46, refillRisk: "Renewal due in 3 days", opportunity: "R 18 400"),
            OutreachMember(id: UUID(), name: "M. Dlamini", condition: "Heart Failure", riskLevel: .critical, adherenceScore: 39, refillRisk: "Refill gap 9 days", opportunity: "R 27 900"),
            OutreachMember(id: UUID(), name: "S. Jacobs", condition: "Type 2 Diabetes", riskLevel: .high, adherenceScore: 52, refillRisk: "Renewal missed", opportunity: "R 14 200")
        ],
        insights: [
            PopulationInsight(id: UUID(), title: "Evening-dose behavior is the biggest drag on adherence.", detail: "Across the population, evening statin and second-daily diabetes doses show the highest miss rate.", icon: "moon.stars.fill"),
            PopulationInsight(id: UUID(), title: "Renewal risk is an early-warning signal.", detail: "Members approaching script renewal with recent misses show a clear increase in defaulting risk.", icon: "calendar.badge.exclamationmark"),
            PopulationInsight(id: UUID(), title: "Earlier outreach can reduce avoidable spend.", detail: "Rising-risk members remain the highest-yield intervention band before acute cost emerges.", icon: "chart.line.uptrend.xyaxis")
        ],
        predictiveInputs: [
            PredictiveNode(id: UUID(), title: "Diagnosis", subtitle: "Diabetes, hypertension, dyslipidaemia", color: Color(hex: "2F6BFF")),
            PredictiveNode(id: UUID(), title: "Medication plan", subtitle: "Dose, frequency, renewal timing", color: Color(hex: "7A63FF")),
            PredictiveNode(id: UUID(), title: "Adherence behavior", subtitle: "Missed doses, streaks, timing patterns", color: Color(hex: "35C98A")),
            PredictiveNode(id: UUID(), title: "Side effects + barriers", subtitle: "Tolerance, routines, friction points", color: Color(hex: "FFB648")),
            PredictiveNode(id: UUID(), title: "Outcomes", subtitle: "Control, follow-up, utilization", color: Color(hex: "FF7A59"))
        ],
        predictiveOutputs: [
            PredictiveNode(id: UUID(), title: "Risk of defaulting", subtitle: "Who may stop treatment soon", color: Color(hex: "FF7A59")),
            PredictiveNode(id: UUID(), title: "Complication risk", subtitle: "Who may deteriorate without action", color: Color(hex: "FF4D5E")),
            PredictiveNode(id: UUID(), title: "Earlier intervention", subtitle: "Who needs coaching, review, or outreach now", color: Color(hex: "2F6BFF")),
            PredictiveNode(id: UUID(), title: "Personalized medicine", subtitle: "Support intensity tailored to behavior", color: Color(hex: "7A63FF"))
        ]
    )

    private static func makeAdherencePattern(_ statuses: [AdherenceStatus]) -> [DailyAdherence] {
        statuses.enumerated().map { index, status in
            DailyAdherence(id: UUID(), day: index + 1, status: status)
        }
    }
}
