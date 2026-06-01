import Foundation

enum QuotaTextFormatter {
    static func percent(_ value: Double) -> String {
        if value >= 10 {
            return "\(Int(value.rounded()))%"
        }
        return String(format: "%.1f%%", value)
    }

    static func todayBudgetContext(
        dailyAllowancePercent: Double,
        weeklyRemainingPercent: Double,
        language: AppLanguage
    ) -> String {
        switch language {
        case .zhHans:
            return "\(percent(dailyAllowancePercent)) / 剩余周额度 \(percent(weeklyRemainingPercent))"
        case .zhHant:
            return "\(percent(dailyAllowancePercent)) / 剩餘週額度 \(percent(weeklyRemainingPercent))"
        case .ja:
            return "\(percent(dailyAllowancePercent)) / 週間残り \(percent(weeklyRemainingPercent))"
        case .ko:
            return "\(percent(dailyAllowancePercent)) / 주간 잔여 \(percent(weeklyRemainingPercent))"
        case .es:
            return "\(percent(dailyAllowancePercent)) / semanal restante \(percent(weeklyRemainingPercent))"
        case .fr:
            return "\(percent(dailyAllowancePercent)) / reste hebdo \(percent(weeklyRemainingPercent))"
        case .de:
            return "\(percent(dailyAllowancePercent)) / Woche übrig \(percent(weeklyRemainingPercent))"
        case .pt:
            return "\(percent(dailyAllowancePercent)) / semanal restante \(percent(weeklyRemainingPercent))"
        case .it:
            return "\(percent(dailyAllowancePercent)) / settimanale residuo \(percent(weeklyRemainingPercent))"
        case .id:
            return "\(percent(dailyAllowancePercent)) / sisa mingguan \(percent(weeklyRemainingPercent))"
        case .th:
            return "\(percent(dailyAllowancePercent)) / คงเหลือรายสัปดาห์ \(percent(weeklyRemainingPercent))"
        default:
            return "\(percent(dailyAllowancePercent)) / weekly remaining \(percent(weeklyRemainingPercent))"
        }
    }

    static func resetSummary(
        resetAt: Date,
        now: Date,
        language: AppLanguage,
        includeWeekday: Bool
    ) -> String {
        let dateText = resetDateText(resetAt, language: language, includeWeekday: includeWeekday)
        let remainingText = remainingDurationText(from: now, to: resetAt, language: language)

        switch language {
        case .zhHans:
            return "\(dateText)恢复 · 还剩\(remainingText)"
        case .zhHant:
            return "\(dateText)恢復 · 還剩\(remainingText)"
        case .ja:
            return "\(dateText)リセット · 残り\(remainingText)"
        case .ko:
            return "\(dateText) 재설정 · \(remainingText) 남음"
        case .es:
            return "\(dateText) reinicia · quedan \(remainingText)"
        case .fr:
            return "\(dateText) réinitialise · reste \(remainingText)"
        case .de:
            return "Reset \(dateText) · \(remainingText) übrig"
        case .pt:
            return "\(dateText) restaura · faltam \(remainingText)"
        case .it:
            return "\(dateText) reset · restano \(remainingText)"
        case .id:
            return "\(dateText) reset · tersisa \(remainingText)"
        case .th:
            return "รีเซ็ต \(dateText) · เหลือ \(remainingText)"
        default:
            return "resets \(dateText) · \(remainingText) left"
        }
    }

    static func remainingDurationText(from start: Date, to end: Date, language: AppLanguage) -> String {
        let interval = max(0, end.timeIntervalSince(start))
        let days = Int(interval / 86_400)
        let hours = Int((interval - Double(days * 86_400)) / 3_600)
        let minutes = max(0, Int((interval - Double(days * 86_400 + hours * 3_600)) / 60))

        switch language {
        case .zhHans:
            if days > 0 {
                return "\(days)天\(hours)小时"
            }
            if hours > 0 {
                return "\(hours)小时\(minutes)分钟"
            }
            return "\(max(1, minutes))分钟"
        case .zhHant:
            if days > 0 {
                return "\(days)天\(hours)小時"
            }
            if hours > 0 {
                return "\(hours)小時\(minutes)分鐘"
            }
            return "\(max(1, minutes))分鐘"
        case .ja:
            if days > 0 {
                return "\(days)日\(hours)時間"
            }
            if hours > 0 {
                return "\(hours)時間\(minutes)分"
            }
            return "\(max(1, minutes))分"
        case .ko:
            if days > 0 {
                return "\(days)일 \(hours)시간"
            }
            if hours > 0 {
                return "\(hours)시간 \(minutes)분"
            }
            return "\(max(1, minutes))분"
        case .es, .pt:
            if days > 0 {
                return "\(days) d \(hours) h"
            }
            if hours > 0 {
                return "\(hours) h \(minutes) min"
            }
            return "\(max(1, minutes)) min"
        case .fr:
            if days > 0 {
                return "\(days) j \(hours) h"
            }
            if hours > 0 {
                return "\(hours) h \(minutes) min"
            }
            return "\(max(1, minutes)) min"
        case .de:
            if days > 0 {
                return "\(days) T \(hours) Std."
            }
            if hours > 0 {
                return "\(hours) Std. \(minutes) Min."
            }
            return "\(max(1, minutes)) Min."
        case .it:
            if days > 0 {
                return "\(days) g \(hours) h"
            }
            if hours > 0 {
                return "\(hours) h \(minutes) min"
            }
            return "\(max(1, minutes)) min"
        case .id:
            if days > 0 {
                return "\(days) hari \(hours) jam"
            }
            if hours > 0 {
                return "\(hours) jam \(minutes) mnt"
            }
            return "\(max(1, minutes)) mnt"
        case .th:
            if days > 0 {
                return "\(days) วัน \(hours) ชม."
            }
            if hours > 0 {
                return "\(hours) ชม. \(minutes) นาที"
            }
            return "\(max(1, minutes)) นาที"
        default:
            if days > 0 {
                return "\(days)d \(hours)h"
            }
            if hours > 0 {
                return "\(hours)h \(minutes)m"
            }
            return "\(max(1, minutes))m"
        }
    }

    static func weekdayText(for date: Date, language: AppLanguage) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale(for: language)
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private static func resetDateText(_ date: Date, language: AppLanguage, includeWeekday: Bool) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale(for: language)
        formatter.dateFormat = includeWeekday ? "E HH:mm" : "HH:mm"
        return formatter.string(from: date)
    }

    static func locale(for language: AppLanguage) -> Locale {
        switch language {
        case .zhHans:
            return Locale(identifier: "zh_CN")
        case .zhHant:
            return Locale(identifier: "zh_TW")
        case .ja:
            return Locale(identifier: "ja_JP")
        case .ko:
            return Locale(identifier: "ko_KR")
        case .es:
            return Locale(identifier: "es_ES")
        case .fr:
            return Locale(identifier: "fr_FR")
        case .de:
            return Locale(identifier: "de_DE")
        case .pt:
            return Locale(identifier: "pt_PT")
        case .it:
            return Locale(identifier: "it_IT")
        case .id:
            return Locale(identifier: "id_ID")
        case .th:
            return Locale(identifier: "th_TH")
        case .en:
            return Locale(identifier: "en_US")
        }
    }
}
