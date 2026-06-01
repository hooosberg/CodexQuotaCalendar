import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case en
    case zhHans
    case zhHant
    case ja
    case ko
    case es
    case fr
    case de
    case pt
    case it
    case id
    case th

    var id: String { rawValue }

    static let supported: [AppLanguage] = AppLanguage.allCases

    var displayName: String {
        switch self {
        case .en: return "English"
        case .zhHans: return "简体中文"
        case .zhHant: return "繁體中文"
        case .ja: return "日本語"
        case .ko: return "한국어"
        case .es: return "Español"
        case .fr: return "Français"
        case .de: return "Deutsch"
        case .pt: return "Português"
        case .it: return "Italiano"
        case .id: return "Indonesia"
        case .th: return "ไทย"
        }
    }
}

enum LocalizedKey: String, CaseIterable, Hashable {
    case appName
    case todayStatus
    case weeklyCycle
    case predictedExhaustion
    case settings
    case about
    case appearanceDay
    case appearanceNight
    case appearanceSystem
    case language
    case refreshNow
    case privacySummary
    case fiveHourWindow
    case weeklyWindow
    case sevenDayPacing
    case monthlyHeatmap
    case notifications
    case aboutBody
    case updatedAt
    case waitingForUsage
    case waitingForUsageBody
    case comfortablePace
    case watchPace
    case pastDailyLine
    case mayRunOutEarly
    case dailyAllowance
    case carryover
    case recentPace
    case noActiveBurnRate
    case remaining
    case basePerDay
    case adjustedPerDay
    case burnPerDay
    case resetCountdown
    case notificationSummary
    case appearance
    case refreshInterval
    case fiveMinutes
    case tenMinutes
    case fifteenMinutes
    case thirtyMinutes
    case oneHour
    case dailyLine
    case overLine
    case projectedExhaustion
    case resetApproaching
    case aboutSubtitle
    case overview
    case todayForecast
    case todayUsed
    case todayRemaining
    case halfHourSpeed
    case expectedTodayRunout
    case systemQuotaStats
    case resetsAt
    case noTodayRunout
    case todayBudgetUsage
    case todayBudget
    case usedAndRemaining
    case todayBudgetStatus
    case dailyAverageAlgorithm
    case dailyAverageFormulaNote
    case weeklyRemaining
    case remainingTime
    case todayUsage
    case usedAndBudget
    case remainingUsable
    case currentPace
    case todayBudgetDepleted
    case runsOutAt
    case remainingQuota
    case algorithmDetails
    case remainingUntilReset
    case sevenDayPacingNote
    case budgetUsageRecord
    case signInWithChatGPT
    case signingIn
    case signInIntro
    case account
    case signedOut
    case signOut
    case authPrivacy
    case weeklyPace
    case noCycleRunout
    case skipDay
    case restoreDay
    case skippedDay
    case todayLabel
    case officialQuotaPage
    case officialQuotaPageNote
    case openOfficialQuotaPage
    case resetWatcherTitle
    case resetWatcherNote
    case followResetWatcher
    case appControls
    case quitApp
    case quitAppNote
    case aboutTagline
    case aboutLocalPromise
    case aboutGithub
    case aboutGithubNote
    case aboutAuthorX
    case aboutAuthorXNote
    case aboutEmail
    case aboutSupportEmail
    case aboutEmailNote
    case aboutLandingPage
    case aboutLandingPageNote
    case aboutVersion
    case aboutUpdateSoftware
    case aboutUpdateSoftwareNote
    case perWeekSuffix
    case perDaySuffix
    case dayUnit
    case dailyAverageFormula
    case activeDaysRebalanced
    case usedPercentLabel
}

enum LocalizationCatalog {
    static let values: [AppLanguage: [LocalizedKey: String]] = [
        .en: base(
            appName: "Codex Quota Calendar", todayStatus: "Today", weeklyCycle: "Weekly Cycle", predictedExhaustion: "Predicted Exhaustion", settings: "Settings", about: "About", appearanceDay: "Day Mode", appearanceNight: "Night Mode", appearanceSystem: "System", language: "Language", refreshNow: "Refresh", privacySummary: "Runs locally. No proxy, no upload, no account switching.", fiveHourWindow: "5-Hour Window", weeklyWindow: "Weekly Window", sevenDayPacing: "Remaining Days", monthlyHeatmap: "Monthly Heatmap", notifications: "Notifications", aboutBody: "Codex Quota Calendar turns weekly Codex quota into a daily rhythm. It records local checkpoints, estimates today's average allowance, and gives you a clearer runout time before the week gets tight."
        ),
        .zhHans: base(
            appName: "Codex 额度日历", todayStatus: "今日状态", weeklyCycle: "一周预算", predictedExhaustion: "预计用完", settings: "设置", about: "关于", appearanceDay: "白天模式", appearanceNight: "夜晚模式", appearanceSystem: "跟随系统", language: "语言", refreshNow: "刷新", privacySummary: "本机运行。不做代理、不上传数据、不切换账号。", fiveHourWindow: "5 小时额度", weeklyWindow: "每周额度", sevenDayPacing: "本周期可用日", monthlyHeatmap: "月历热力", notifications: "提醒", aboutBody: "Codex 额度日历把每周 Codex 额度换算成每天可用的节奏。它会记录本机历史点位，估算今日平均额度，并给出更清楚的用完时间。"
        ),
        .zhHant: base(appName: "Codex 額度日曆", todayStatus: "今日狀態", weeklyCycle: "週期額度", predictedExhaustion: "預計用完", settings: "設定", about: "關於", appearanceDay: "白天模式", appearanceNight: "夜晚模式", appearanceSystem: "跟隨系統", language: "語言", refreshNow: "重新整理", privacySummary: "本機運行。不做代理、不上傳資料、不切換帳號。", fiveHourWindow: "5 小時額度", weeklyWindow: "每週額度", sevenDayPacing: "7 天節奏", monthlyHeatmap: "月曆熱力", notifications: "提醒", aboutBody: "Codex 額度日曆把每週 Codex 額度換算成每日可用節奏。它會記錄本機歷史點位，估算今日平均額度，並給出更清楚的用完時間。"),
        .ja: base(appName: "Codex Quota Calendar", todayStatus: "今日", weeklyCycle: "週間サイクル", predictedExhaustion: "予測消尽", settings: "設定", about: "このアプリについて", appearanceDay: "ライト", appearanceNight: "ダーク", appearanceSystem: "システム", language: "言語", refreshNow: "更新", privacySummary: "ローカルで動作。プロキシ、アップロード、アカウント切替なし。", fiveHourWindow: "5時間枠", weeklyWindow: "週間枠", sevenDayPacing: "残り利用日", monthlyHeatmap: "月間ヒートマップ", notifications: "通知", aboutBody: "Codex Quota Calendar は、週間 Codex クォータを日々の利用ペースに変換します。ローカルの記録点を使って今日の平均枠を推定し、週が厳しくなる前に分かりやすい消尽時刻を示します。"),
        .ko: base(appName: "Codex Quota Calendar", todayStatus: "오늘", weeklyCycle: "주간 주기", predictedExhaustion: "예상 소진", settings: "설정", about: "정보", appearanceDay: "라이트 모드", appearanceNight: "다크 모드", appearanceSystem: "시스템", language: "언어", refreshNow: "새로고침", privacySummary: "로컬 실행. 프록시, 업로드, 계정 전환 없음.", fiveHourWindow: "5시간 창", weeklyWindow: "주간 창", sevenDayPacing: "남은 사용일", monthlyHeatmap: "월간 히트맵", notifications: "알림", aboutBody: "Codex Quota Calendar는 주간 Codex 한도를 일일 사용 리듬으로 바꿉니다. 로컬 기록 지점을 바탕으로 오늘의 평균 한도를 추정하고, 주간 한도가 빡빡해지기 전에 더 명확한 소진 시간을 보여 줍니다."),
        .es: base(appName: "Codex Quota Calendar", todayStatus: "Hoy", weeklyCycle: "Ciclo semanal", predictedExhaustion: "Agotamiento previsto", settings: "Ajustes", about: "Acerca de", appearanceDay: "Modo claro", appearanceNight: "Modo oscuro", appearanceSystem: "Sistema", language: "Idioma", refreshNow: "Actualizar", privacySummary: "Funciona localmente. Sin proxy, subidas ni cambio de cuenta.", fiveHourWindow: "Ventana de 5 h", weeklyWindow: "Ventana semanal", sevenDayPacing: "Días restantes", monthlyHeatmap: "Mapa mensual", notifications: "Notificaciones", aboutBody: "Codex Quota Calendar convierte la cuota semanal de Codex en un ritmo diario. Registra puntos locales, estima la cuota media de hoy y muestra una hora de agotamiento más clara antes de que la semana se complique."),
        .fr: base(appName: "Codex Quota Calendar", todayStatus: "Aujourd'hui", weeklyCycle: "Cycle hebdo", predictedExhaustion: "Épuisement prévu", settings: "Réglages", about: "À propos", appearanceDay: "Mode clair", appearanceNight: "Mode sombre", appearanceSystem: "Système", language: "Langue", refreshNow: "Actualiser", privacySummary: "Fonctionne en local. Pas de proxy, d'envoi ni de changement de compte.", fiveHourWindow: "Fenêtre 5 h", weeklyWindow: "Fenêtre hebdo", sevenDayPacing: "Jours restants", monthlyHeatmap: "Carte mensuelle", notifications: "Notifications", aboutBody: "Codex Quota Calendar transforme le quota hebdomadaire Codex en rythme quotidien. Il enregistre des points locaux, estime l'allocation moyenne du jour et donne une heure d'épuisement plus lisible avant que la semaine ne devienne serrée."),
        .de: base(appName: "Codex Quota Calendar", todayStatus: "Heute", weeklyCycle: "Wochenzyklus", predictedExhaustion: "Prognose leer", settings: "Einstellungen", about: "Info", appearanceDay: "Hell", appearanceNight: "Dunkel", appearanceSystem: "System", language: "Sprache", refreshNow: "Aktualisieren", privacySummary: "Läuft lokal. Kein Proxy, Upload oder Kontowechsel.", fiveHourWindow: "5-Stunden-Fenster", weeklyWindow: "Wochenfenster", sevenDayPacing: "Resttage", monthlyHeatmap: "Monatskarte", notifications: "Mitteilungen", aboutBody: "Codex Quota Calendar wandelt dein wöchentliches Codex-Kontingent in einen Tagesrhythmus um. Es speichert lokale Messpunkte, schätzt das heutige Durchschnittskontingent und zeigt eine klarere Leerzeit, bevor die Woche eng wird."),
        .pt: base(appName: "Codex Quota Calendar", todayStatus: "Hoje", weeklyCycle: "Ciclo semanal", predictedExhaustion: "Esgotamento previsto", settings: "Ajustes", about: "Sobre", appearanceDay: "Modo claro", appearanceNight: "Modo escuro", appearanceSystem: "Sistema", language: "Idioma", refreshNow: "Atualizar", privacySummary: "Roda localmente. Sem proxy, envio ou troca de conta.", fiveHourWindow: "Janela de 5 h", weeklyWindow: "Janela semanal", sevenDayPacing: "Dias restantes", monthlyHeatmap: "Mapa mensal", notifications: "Notificações", aboutBody: "Codex Quota Calendar transforma a cota semanal do Codex em um ritmo diário. Ele registra pontos locais, estima a cota média de hoje e mostra um horário de esgotamento mais claro antes da semana apertar."),
        .it: base(appName: "Codex Quota Calendar", todayStatus: "Oggi", weeklyCycle: "Ciclo settimanale", predictedExhaustion: "Esaurimento stimato", settings: "Impostazioni", about: "Informazioni", appearanceDay: "Modalità chiara", appearanceNight: "Modalità scura", appearanceSystem: "Sistema", language: "Lingua", refreshNow: "Aggiorna", privacySummary: "Funziona in locale. Nessun proxy, upload o cambio account.", fiveHourWindow: "Finestra 5 ore", weeklyWindow: "Finestra settimanale", sevenDayPacing: "Giorni restanti", monthlyHeatmap: "Mappa mensile", notifications: "Notifiche", aboutBody: "Codex Quota Calendar trasforma la quota settimanale di Codex in un ritmo giornaliero. Registra punti locali, stima la quota media di oggi e mostra un orario di esaurimento più chiaro prima che la settimana diventi stretta."),
        .id: base(appName: "Codex Quota Calendar", todayStatus: "Hari ini", weeklyCycle: "Siklus mingguan", predictedExhaustion: "Perkiraan habis", settings: "Pengaturan", about: "Tentang", appearanceDay: "Mode terang", appearanceNight: "Mode gelap", appearanceSystem: "Sistem", language: "Bahasa", refreshNow: "Segarkan", privacySummary: "Berjalan lokal. Tanpa proxy, unggahan, atau ganti akun.", fiveHourWindow: "Jendela 5 jam", weeklyWindow: "Jendela mingguan", sevenDayPacing: "Hari tersisa", monthlyHeatmap: "Peta bulanan", notifications: "Notifikasi", aboutBody: "Codex Quota Calendar mengubah kuota mingguan Codex menjadi ritme harian. Aplikasi ini mencatat titik lokal, memperkirakan jatah rata-rata hari ini, dan memberi waktu habis yang lebih jelas sebelum minggu terasa sempit."),
        .th: base(appName: "Codex Quota Calendar", todayStatus: "วันนี้", weeklyCycle: "รอบรายสัปดาห์", predictedExhaustion: "คาดว่าจะหมด", settings: "การตั้งค่า", about: "เกี่ยวกับ", appearanceDay: "โหมดสว่าง", appearanceNight: "โหมดมืด", appearanceSystem: "ระบบ", language: "ภาษา", refreshNow: "รีเฟรช", privacySummary: "ทำงานในเครื่อง ไม่พร็อกซี ไม่อัปโหลด ไม่สลับบัญชี", fiveHourWindow: "หน้าต่าง 5 ชม.", weeklyWindow: "หน้าต่างรายสัปดาห์", sevenDayPacing: "วันที่เหลือ", monthlyHeatmap: "แผนที่รายเดือน", notifications: "การแจ้งเตือน", aboutBody: "Codex Quota Calendar แปลงโควตา Codex รายสัปดาห์ให้เป็นจังหวะการใช้รายวัน บันทึกจุดข้อมูลในเครื่อง ประเมินโควตาเฉลี่ยของวันนี้ และแสดงเวลาที่อาจใช้หมดให้ชัดขึ้นก่อนสัปดาห์จะตึงเกินไป")
    ]

    static func text(_ key: LocalizedKey, language: AppLanguage) -> String {
        supplementalValues[language]?[key]
            ?? values[language]?[key]
            ?? supplementalValues[.en]?[key]
            ?? values[.en]?[key]
            ?? key.rawValue
    }

    private static let supplementalValues: [AppLanguage: [LocalizedKey: String]] = [
        .zhHans: [
            .updatedAt: "已更新 %@",
            .waitingForUsage: "等待 Codex 用量",
            .waitingForUsageBody: "登录 ChatGPT 后，额度日历会在本机保存授权并读取真实额度。",
            .comfortablePace: "节奏舒适",
            .watchPace: "接近今日线",
            .pastDailyLine: "已超过今日线",
            .mayRunOutEarly: "可能提前用完",
            .dailyAllowance: "今日可用",
            .carryover: "结余/透支",
            .recentPace: "当前速度",
            .noActiveBurnRate: "暂无消耗速度",
            .remaining: "剩余",
            .basePerDay: "基础/天",
            .adjustedPerDay: "调整/天",
            .burnPerDay: "速度/天",
            .resetCountdown: "%@天 %@小时后恢复",
            .notificationSummary: "今日线、超额和预计用完提醒",
            .appearance: "外观",
            .refreshInterval: "刷新频率",
            .fiveMinutes: "5 分钟",
            .tenMinutes: "10 分钟",
            .fifteenMinutes: "15 分钟",
            .thirtyMinutes: "30 分钟",
            .oneHour: "1 小时",
            .dailyLine: "达到今日线",
            .overLine: "超过 110%",
            .projectedExhaustion: "预计提前用完",
            .resetApproaching: "恢复日前提醒",
            .aboutSubtitle: "每日额度计算与节奏预估",
            .overview: "总览",
            .todayForecast: "今日预估",
            .todayUsed: "今日已用",
            .todayRemaining: "今日剩余",
            .halfHourSpeed: "份额速度",
            .expectedTodayRunout: "今日平均额度预估用完时间",
            .systemQuotaStats: "系统原始额度",
            .resetsAt: "恢复 %@",
            .noTodayRunout: "今天不会用完",
            .todayBudgetUsage: "今日份额已用",
            .todayBudget: "今日份额",
            .usedAndRemaining: "已用 / 剩余",
            .todayBudgetStatus: "预算状态",
            .dailyAverageAlgorithm: "每日平均算法",
            .dailyAverageFormulaNote: "每天刷新后重新计算。今天少用会留给后面，今天超用会压缩后续每日预算。",
            .weeklyRemaining: "剩余周额度",
            .remainingTime: "剩余时间",
            .todayUsage: "今日使用情况",
            .usedAndBudget: "已用 / 预算",
            .remainingUsable: "剩余可用",
            .currentPace: "按当前速度",
            .todayBudgetDepleted: "已用完今日预算",
            .runsOutAt: "%@ 用完",
            .remainingQuota: "剩余额度",
            .algorithmDetails: "算法说明",
            .remainingUntilReset: "还剩 %@",
            .sevenDayPacingNote: "记录本机每天已用 / 今日预算的百分比；刚安装时会从 0 开始累积。",
            .budgetUsageRecord: "预算使用率",
            .signInWithChatGPT: "使用 ChatGPT 登录",
            .signingIn: "等待浏览器授权...",
            .signInIntro: "新用户第一次使用需要授权。登录完成后，额度日历会自动回到这里并刷新真实额度。",
            .account: "账号",
            .signedOut: "未登录",
            .signOut: "退出登录",
            .authPrivacy: "授权 token 只保存在本机，不上传到任何服务器。",
            .weeklyPace: "本周按此速度",
            .noCycleRunout: "本周期不会用完",
            .skipDay: "设为休息，重新平均预算",
            .restoreDay: "恢复为可用日",
            .skippedDay: "休息",
            .todayLabel: "今天",
            .officialQuotaPage: "官方用量页面",
            .officialQuotaPageNote: "打开官方页面核对剩余额度；本工具只做本机记录和每日平均估算。",
            .openOfficialQuotaPage: "打开官方用量页面",
            .resetWatcherTitle: "赛博重置上帝 @thsottiaux",
            .resetWatcherNote: "点击关注重置情况，顺便给额度焦虑加一点幽默感。",
            .followResetWatcher: "关注重置情况",
            .appControls: "应用",
            .quitApp: "关闭额度日历",
            .quitAppNote: "退出菜单栏应用；下次可从启动台或应用文件夹重新打开。",
            .aboutTagline: "把 Codex 剩余额度换算成今天该怎么用。",
            .aboutLocalPromise: "本工具只在本机保存授权、用量日志和每日基准线；不做代理，不上传数据，也不会帮你切换账号。",
            .aboutGithub: "GitHub",
            .aboutGithubNote: "查看作者主页，后续项目页面也会从这里展开。",
            .aboutAuthorX: "作者 X",
            .aboutAuthorXNote: "打开作者的 X 主页，关注更新和反馈。",
            .aboutEmail: "反馈邮箱",
            .aboutSupportEmail: "zikedece@proton.me",
            .aboutEmailNote: "遇到额度计算不准、重置异常或界面问题，可以直接发邮件。",
            .aboutLandingPage: "产品落地页",
            .aboutLandingPageNote: "稍后会在 GitHub Pages 放产品介绍、截图和使用说明。",
            .aboutVersion: "版本",
            .aboutUpdateSoftware: "检查更新",
            .aboutUpdateSoftwareNote: "打开 GitHub Releases 下载最新版。",
            .perWeekSuffix: "/周",
            .perDaySuffix: "/天",
            .dayUnit: "天",
            .dailyAverageFormula: "%@ ÷ %d 天 = %@/天",
            .activeDaysRebalanced: "已按 %d 个可用日重新平均",
            .usedPercentLabel: "已用 %@"
        ],
        .en: [
            .updatedAt: "Updated %@",
            .waitingForUsage: "Waiting for Codex usage",
            .waitingForUsageBody: "Sign in with ChatGPT. Quota Calendar stores local auth and reads real quota data.",
            .comfortablePace: "Comfortable pace",
            .watchPace: "Watch today's pace",
            .pastDailyLine: "Past the daily line",
            .mayRunOutEarly: "May run out early",
            .dailyAllowance: "Daily allowance",
            .carryover: "Carryover",
            .recentPace: "Recent pace",
            .noActiveBurnRate: "No active burn rate",
            .remaining: "Remaining",
            .basePerDay: "Base/day",
            .adjustedPerDay: "Adjusted/day",
            .burnPerDay: "Burn/day",
            .resetCountdown: "%@d %@h to reset",
            .notificationSummary: "Daily line, over-line, and projected exhaustion alerts",
            .appearance: "Appearance",
            .refreshInterval: "Refresh",
            .fiveMinutes: "5 min",
            .tenMinutes: "10 min",
            .fifteenMinutes: "15 min",
            .thirtyMinutes: "30 min",
            .oneHour: "1 hour",
            .dailyLine: "Daily line",
            .overLine: "Over 110%",
            .projectedExhaustion: "Projected exhaustion",
            .resetApproaching: "Reset approaching",
            .aboutSubtitle: "Daily quota calculator and pacing estimate",
            .overview: "Overview",
            .todayForecast: "Today Forecast",
            .todayUsed: "Used Today",
            .todayRemaining: "Today Remaining",
            .halfHourSpeed: "Share Speed",
            .expectedTodayRunout: "Daily Avg Runout",
            .systemQuotaStats: "System Quota Stats",
            .resetsAt: "resets %@",
            .noTodayRunout: "Will not run out today",
            .todayBudgetUsage: "Today Share Used",
            .todayBudget: "Today Share",
            .usedAndRemaining: "Used / Remaining",
            .todayBudgetStatus: "Budget Status",
            .dailyAverageAlgorithm: "Daily Average Formula",
            .dailyAverageFormulaNote: "Recalculated after each refresh. Under-use carries forward; over-use reduces the next daily budgets.",
            .weeklyRemaining: "Weekly Remaining",
            .remainingTime: "Time Left",
            .todayUsage: "Today Usage",
            .usedAndBudget: "Used / Budget",
            .remainingUsable: "Remaining",
            .currentPace: "Current Pace",
            .todayBudgetDepleted: "Today's budget used",
            .runsOutAt: "Runs out %@",
            .remainingQuota: "Remaining Quota",
            .algorithmDetails: "Formula",
            .remainingUntilReset: "%@ left",
            .sevenDayPacingNote: "Records each day's used quota divided by today's budget; new installs start from 0.",
            .budgetUsageRecord: "Budget Usage",
            .signInWithChatGPT: "Sign in with ChatGPT",
            .signingIn: "Waiting for browser authorization...",
            .signInIntro: "First-time users need to authorize. After login, Quota Calendar returns here and refreshes real quota data.",
            .account: "Account",
            .signedOut: "Signed out",
            .signOut: "Sign Out",
            .authPrivacy: "Auth tokens are stored only on this Mac and are never uploaded.",
            .weeklyPace: "Weekly Pace",
            .noCycleRunout: "Will not run out this cycle",
            .skipDay: "Mark as rest day and rebalance",
            .restoreDay: "Restore as available day",
            .skippedDay: "Rest",
            .todayLabel: "Today",
            .officialQuotaPage: "Official Usage Page",
            .officialQuotaPageNote: "Open the official page to compare remaining quota. This app only records locally and estimates daily pacing.",
            .openOfficialQuotaPage: "Open Official Usage Page",
            .resetWatcherTitle: "Cyber Reset God @thsottiaux",
            .resetWatcherNote: "Follow reset sightings and keep quota anxiety slightly funnier.",
            .followResetWatcher: "Follow reset status",
            .appControls: "App",
            .quitApp: "Quit Codex Quota Calendar",
            .quitAppNote: "Quit the menu bar app. Reopen it later from Launchpad or Applications.",
            .aboutTagline: "Turn remaining Codex quota into today's usable rhythm.",
            .aboutLocalPromise: "This tool stores auth, usage logs, and daily baselines only on this Mac. No proxy, no upload, no account switching.",
            .aboutGithub: "GitHub",
            .aboutGithubNote: "Open the author profile. The project page will grow from there.",
            .aboutAuthorX: "Author X",
            .aboutAuthorXNote: "Open the author's X profile for updates and feedback.",
            .aboutEmail: "Email",
            .aboutSupportEmail: "zikedece@proton.me",
            .aboutEmailNote: "Send feedback for quota math, reset issues, or UI problems.",
            .aboutLandingPage: "Product Page",
            .aboutLandingPageNote: "A GitHub Pages landing page with intro, screenshots, and docs will come later.",
            .aboutVersion: "Version",
            .aboutUpdateSoftware: "Check for Updates",
            .aboutUpdateSoftwareNote: "Open GitHub Releases to download the latest version.",
            .perWeekSuffix: "/week",
            .perDaySuffix: "/day",
            .dayUnit: "days",
            .dailyAverageFormula: "%@ ÷ %d days = %@/day",
            .activeDaysRebalanced: "Rebalanced across %d available days",
            .usedPercentLabel: "Used %@"
        ],
        .zhHant: [
            .updatedAt: "已更新 %@",
            .waitingForUsage: "等待 Codex 用量",
            .waitingForUsageBody: "登入 ChatGPT 後，額度日曆會在本機保存授權並讀取真實額度。",
            .comfortablePace: "節奏舒適",
            .watchPace: "接近今日線",
            .pastDailyLine: "已超過今日線",
            .mayRunOutEarly: "可能提前用完",
            .noActiveBurnRate: "暫無消耗速度",
            .notificationSummary: "今日線、超額和預計用完提醒",
            .appearance: "外觀",
            .refreshInterval: "重新整理頻率",
            .fiveMinutes: "5 分鐘",
            .tenMinutes: "10 分鐘",
            .fifteenMinutes: "15 分鐘",
            .thirtyMinutes: "30 分鐘",
            .oneHour: "1 小時",
            .dailyLine: "達到今日線",
            .overLine: "超過 110%",
            .resetApproaching: "恢復日前提醒",
            .aboutSubtitle: "每日額度計算與節奏預估",
            .overview: "總覽",
            .expectedTodayRunout: "今日平均額度預估用完時間",
            .systemQuotaStats: "系統原始額度",
            .resetsAt: "恢復 %@",
            .noTodayRunout: "今天不會用完",
            .todayBudgetUsage: "今日份額已用",
            .todayBudget: "今日份額",
            .dailyAverageAlgorithm: "每日平均算法",
            .dailyAverageFormulaNote: "每天重新整理後重新計算。今天少用會留給後面，今天超用會壓縮後續每日預算。",
            .todayUsage: "今日使用情況",
            .todayBudgetDepleted: "已用完今日預算",
            .runsOutAt: "%@ 用完",
            .signInWithChatGPT: "使用 ChatGPT 登入",
            .signingIn: "等待瀏覽器授權...",
            .signInIntro: "首次使用需要授權。登入完成後，額度日曆會自動回到這裡並重新整理真實額度。",
            .account: "帳號",
            .signedOut: "未登入",
            .signOut: "登出",
            .authPrivacy: "授權 token 只保存在本機，不會上傳到任何伺服器。",
            .skipDay: "設為休息，重新平均預算",
            .restoreDay: "恢復為可用日",
            .skippedDay: "休息",
            .todayLabel: "今天",
            .officialQuotaPage: "官方用量頁面",
            .officialQuotaPageNote: "打開官方頁面核對剩餘額度；本工具只做本機記錄和每日平均估算。",
            .resetWatcherTitle: "賽博重置上帝 @thsottiaux",
            .resetWatcherNote: "點擊關注重置情況，順便給額度焦慮加一點幽默感。",
            .appControls: "應用",
            .quitApp: "關閉額度日曆",
            .quitAppNote: "退出選單列應用；下次可從啟動台或應用程式資料夾重新打開。",
            .aboutTagline: "把 Codex 剩餘額度換算成今天該怎麼用。",
            .aboutLocalPromise: "本工具只在本機保存授權、用量日誌和每日基準線；不做代理，不上傳資料，也不會幫你切換帳號。",
            .aboutGithub: "GitHub",
            .aboutGithubNote: "查看作者主頁，後續專案頁面也會從這裡展開。",
            .aboutAuthorX: "作者 X",
            .aboutAuthorXNote: "打開作者的 X 主頁，關注更新和回饋。",
            .aboutEmail: "回饋信箱",
            .aboutSupportEmail: "zikedece@proton.me",
            .aboutEmailNote: "遇到額度計算不準、重置異常或介面問題，可以直接發郵件。",
            .aboutLandingPage: "產品落地頁",
            .aboutLandingPageNote: "稍後會在 GitHub Pages 放產品介紹、截圖和使用說明。",
            .aboutVersion: "版本",
            .aboutUpdateSoftware: "檢查更新",
            .aboutUpdateSoftwareNote: "打開 GitHub Releases 下載最新版。",
            .perWeekSuffix: "/週",
            .perDaySuffix: "/天",
            .dayUnit: "天",
            .dailyAverageFormula: "%@ ÷ %d 天 = %@/天",
            .activeDaysRebalanced: "已按 %d 個可用日重新平均",
            .usedPercentLabel: "已用 %@"
        ],
        .ja: [
            .updatedAt: "%@ 更新",
            .waitingForUsage: "Codex 使用量を待機中",
            .waitingForUsageBody: "ChatGPT にサインインすると、認証情報をこの Mac に保存して実際のクォータを読み取ります。",
            .comfortablePace: "余裕のあるペース",
            .watchPace: "今日のラインに接近",
            .pastDailyLine: "今日のライン超過",
            .mayRunOutEarly: "早めに尽きる可能性",
            .noActiveBurnRate: "消費速度なし",
            .notificationSummary: "今日ライン、超過、予測消尽の通知",
            .appearance: "外観",
            .refreshInterval: "更新間隔",
            .fiveMinutes: "5 分",
            .tenMinutes: "10 分",
            .fifteenMinutes: "15 分",
            .thirtyMinutes: "30 分",
            .oneHour: "1 時間",
            .dailyLine: "今日ライン",
            .overLine: "110% 超過",
            .resetApproaching: "リセット前通知",
            .aboutSubtitle: "日次クォータ計算とペース予測",
            .overview: "概要",
            .expectedTodayRunout: "日次平均枠の消尽予測",
            .systemQuotaStats: "システム元クォータ",
            .resetsAt: "%@ にリセット",
            .noTodayRunout: "今日は使い切りません",
            .todayBudgetUsage: "今日枠の使用率",
            .todayBudget: "今日枠",
            .dailyAverageAlgorithm: "日次平均アルゴリズム",
            .dailyAverageFormulaNote: "更新ごとに再計算します。今日少なく使えば後日に回り、多く使えば後日の予算が圧縮されます。",
            .todayUsage: "今日の使用状況",
            .todayBudgetDepleted: "今日の予算を使い切りました",
            .runsOutAt: "%@ に消尽",
            .signInWithChatGPT: "ChatGPT でサインイン",
            .signingIn: "ブラウザ認証を待機中...",
            .signInIntro: "初回利用には認証が必要です。ログイン後、この画面に戻って実際のクォータを更新します。",
            .account: "アカウント",
            .signedOut: "未サインイン",
            .signOut: "サインアウト",
            .authPrivacy: "認証トークンはこの Mac のみに保存され、アップロードされません。",
            .skipDay: "休みにして予算を再配分",
            .restoreDay: "利用日に戻す",
            .skippedDay: "休み",
            .todayLabel: "今日",
            .officialQuotaPage: "公式使用量ページ",
            .officialQuotaPageNote: "公式ページで残りクォータを確認します。このツールはローカル記録と日次平均推定のみを行います。",
            .resetWatcherTitle: "サイバーリセット神 @thsottiaux",
            .resetWatcherNote: "リセット状況を追って、クォータ不安を少しだけ軽くします。",
            .appControls: "アプリ",
            .quitApp: "Codex Quota Calendar を終了",
            .quitAppNote: "メニューバーアプリを終了します。後で Launchpad またはアプリケーションから開けます。",
            .aboutTagline: "残り Codex クォータを今日の使い方に変換します。",
            .aboutLocalPromise: "認証、使用ログ、日次基準線はこの Mac のみに保存されます。プロキシ、アップロード、アカウント切替はありません。",
            .aboutGithub: "GitHub",
            .aboutGithubNote: "作者プロフィールを開きます。今後の製品ページもここから展開します。",
            .aboutAuthorX: "作者の X",
            .aboutAuthorXNote: "作者の X プロフィールを開いて、更新やフィードバックを確認します。",
            .aboutEmail: "メール",
            .aboutSupportEmail: "zikedece@proton.me",
            .aboutEmailNote: "計算、リセット、UI の問題をメールで送れます。",
            .aboutLandingPage: "製品ページ",
            .aboutLandingPageNote: "後で GitHub Pages に紹介、スクリーンショット、使い方を掲載します。",
            .aboutVersion: "バージョン",
            .aboutUpdateSoftware: "アップデートを確認",
            .aboutUpdateSoftwareNote: "GitHub Releases を開いて最新版をダウンロードします。",
            .perWeekSuffix: "/週",
            .perDaySuffix: "/日",
            .dayUnit: "日",
            .dailyAverageFormula: "%@ ÷ %d 日 = %@/日",
            .activeDaysRebalanced: "%d 利用日に再配分済み",
            .usedPercentLabel: "%@ 使用"
        ],
        .ko: [
            .updatedAt: "%@ 업데이트",
            .waitingForUsage: "Codex 사용량 대기 중",
            .waitingForUsageBody: "ChatGPT에 로그인하면 인증 정보를 이 Mac에 저장하고 실제 한도를 읽습니다.",
            .comfortablePace: "여유 있는 속도",
            .watchPace: "오늘 기준선에 가까움",
            .pastDailyLine: "오늘 기준선 초과",
            .mayRunOutEarly: "일찍 소진될 수 있음",
            .noActiveBurnRate: "소모 속도 없음",
            .notificationSummary: "오늘 기준선, 초과, 예상 소진 알림",
            .appearance: "모양",
            .refreshInterval: "새로고침 간격",
            .fiveMinutes: "5분",
            .tenMinutes: "10분",
            .fifteenMinutes: "15분",
            .thirtyMinutes: "30분",
            .oneHour: "1시간",
            .dailyLine: "오늘 기준선",
            .overLine: "110% 초과",
            .resetApproaching: "재설정 전 알림",
            .aboutSubtitle: "일일 한도 계산과 속도 예측",
            .overview: "개요",
            .expectedTodayRunout: "일일 평균 한도 예상 소진 시간",
            .systemQuotaStats: "시스템 원본 한도",
            .resetsAt: "%@ 재설정",
            .noTodayRunout: "오늘은 소진되지 않음",
            .todayBudgetUsage: "오늘 몫 사용률",
            .todayBudget: "오늘 몫",
            .dailyAverageAlgorithm: "일일 평균 계산식",
            .dailyAverageFormulaNote: "새로고침할 때마다 다시 계산합니다. 오늘 덜 쓰면 뒤로 넘어가고, 초과 사용하면 이후 일일 예산이 줄어듭니다.",
            .todayUsage: "오늘 사용 현황",
            .todayBudgetDepleted: "오늘 예산을 모두 사용함",
            .runsOutAt: "%@ 소진",
            .signInWithChatGPT: "ChatGPT로 로그인",
            .signingIn: "브라우저 인증 대기 중...",
            .signInIntro: "처음 사용할 때는 인증이 필요합니다. 로그인 후 이 화면으로 돌아와 실제 한도를 새로고침합니다.",
            .account: "계정",
            .signedOut: "로그아웃됨",
            .signOut: "로그아웃",
            .authPrivacy: "인증 토큰은 이 Mac에만 저장되며 업로드되지 않습니다.",
            .skipDay: "휴식일로 설정하고 예산 재분배",
            .restoreDay: "사용일로 복원",
            .skippedDay: "휴식",
            .todayLabel: "오늘",
            .officialQuotaPage: "공식 사용량 페이지",
            .officialQuotaPageNote: "공식 페이지에서 남은 한도를 확인합니다. 이 도구는 로컬 기록과 일일 평균 추정만 수행합니다.",
            .resetWatcherTitle: "사이버 리셋 신 @thsottiaux",
            .resetWatcherNote: "재설정 상황을 확인하고 한도 불안에 약간의 유머를 더합니다.",
            .appControls: "앱",
            .quitApp: "Codex Quota Calendar 종료",
            .quitAppNote: "메뉴 막대 앱을 종료합니다. 나중에 Launchpad 또는 응용 프로그램에서 다시 열 수 있습니다.",
            .aboutTagline: "남은 Codex 한도를 오늘 쓸 수 있는 리듬으로 바꿉니다.",
            .aboutLocalPromise: "인증, 사용 로그, 일일 기준선은 이 Mac에만 저장됩니다. 프록시, 업로드, 계정 전환은 없습니다.",
            .aboutGithub: "GitHub",
            .aboutGithubNote: "작성자 프로필을 엽니다. 이후 프로젝트 페이지도 여기서 이어집니다.",
            .aboutAuthorX: "작성자 X",
            .aboutAuthorXNote: "작성자의 X 프로필을 열어 업데이트와 피드백을 확인합니다.",
            .aboutEmail: "이메일",
            .aboutSupportEmail: "zikedece@proton.me",
            .aboutEmailNote: "한도 계산, 재설정, UI 문제를 이메일로 보내 주세요.",
            .aboutLandingPage: "제품 페이지",
            .aboutLandingPageNote: "이후 GitHub Pages에 소개, 스크린샷, 사용법을 올릴 예정입니다.",
            .aboutVersion: "버전",
            .aboutUpdateSoftware: "업데이트 확인",
            .aboutUpdateSoftwareNote: "GitHub Releases에서 최신 버전을 다운로드합니다.",
            .perWeekSuffix: "/주",
            .perDaySuffix: "/일",
            .dayUnit: "일",
            .dailyAverageFormula: "%@ ÷ %d일 = %@/일",
            .activeDaysRebalanced: "사용 가능일 %d일 기준으로 재분배됨",
            .usedPercentLabel: "%@ 사용"
        ],
        .es: [
            .updatedAt: "Actualizado %@",
            .comfortablePace: "Ritmo cómodo",
            .noActiveBurnRate: "Sin ritmo de consumo",
            .appearance: "Apariencia",
            .refreshInterval: "Frecuencia",
            .fiveMinutes: "5 min",
            .tenMinutes: "10 min",
            .fifteenMinutes: "15 min",
            .thirtyMinutes: "30 min",
            .oneHour: "1 hora",
            .dailyLine: "Línea diaria",
            .overLine: "Más de 110%",
            .resetApproaching: "Aviso antes del reinicio",
            .aboutSubtitle: "Cálculo diario y ritmo estimado",
            .overview: "Resumen",
            .expectedTodayRunout: "Hora estimada de fin diario",
            .systemQuotaStats: "Cuota original",
            .noTodayRunout: "No se agotará hoy",
            .todayBudgetUsage: "Uso de cuota de hoy",
            .todayBudget: "Cuota de hoy",
            .dailyAverageAlgorithm: "Fórmula diaria media",
            .dailyAverageFormulaNote: "Se recalcula tras cada actualización. Si usas menos hoy, se guarda para después; si usas más, reduce los presupuestos siguientes.",
            .todayUsage: "Uso de hoy",
            .todayBudgetDepleted: "Presupuesto de hoy agotado",
            .runsOutAt: "Se agota %@",
            .account: "Cuenta",
            .signOut: "Cerrar sesión",
            .authPrivacy: "Los tokens de autorización solo se guardan en este Mac y nunca se suben.",
            .skippedDay: "Descanso",
            .todayLabel: "Hoy",
            .officialQuotaPage: "Página oficial de uso",
            .officialQuotaPageNote: "Abre la página oficial para comprobar la cuota restante; esta app solo registra localmente y estima el ritmo diario.",
            .appControls: "Aplicación",
            .quitApp: "Salir de Codex Quota Calendar",
            .quitAppNote: "Cierra la app de la barra de menús. Puedes abrirla luego desde Launchpad o Aplicaciones.",
            .aboutTagline: "Convierte la cuota restante de Codex en el ritmo usable de hoy.",
            .aboutLocalPromise: "Esta herramienta guarda autorización, registros y líneas base solo en este Mac. Sin proxy, subidas ni cambio de cuenta.",
            .aboutGithub: "GitHub",
            .aboutGithubNote: "Abre el perfil del autor. La página del proyecto crecerá desde allí.",
            .aboutAuthorX: "X del autor",
            .aboutAuthorXNote: "Abre el perfil de X del autor para actualizaciones y comentarios.",
            .aboutEmail: "Email",
            .aboutSupportEmail: "zikedece@proton.me",
            .aboutEmailNote: "Envía comentarios sobre cálculo, reinicios o interfaz.",
            .aboutLandingPage: "Página del producto",
            .aboutLandingPageNote: "Más adelante habrá una página en GitHub Pages con introducción, capturas y guía.",
            .aboutVersion: "Versión",
            .aboutUpdateSoftware: "Buscar actualizaciones",
            .aboutUpdateSoftwareNote: "Abre GitHub Releases para descargar la última versión.",
            .perWeekSuffix: "/sem",
            .perDaySuffix: "/día",
            .dayUnit: "días",
            .dailyAverageFormula: "%@ ÷ %d días = %@/día",
            .activeDaysRebalanced: "Recalculado sobre %d días disponibles",
            .usedPercentLabel: "Usado %@"
        ],
        .fr: [
            .updatedAt: "Mis à jour %@",
            .comfortablePace: "Rythme confortable",
            .noActiveBurnRate: "Aucun rythme actif",
            .appearance: "Apparence",
            .refreshInterval: "Fréquence",
            .fiveMinutes: "5 min",
            .tenMinutes: "10 min",
            .fifteenMinutes: "15 min",
            .thirtyMinutes: "30 min",
            .oneHour: "1 h",
            .dailyLine: "Ligne du jour",
            .overLine: "Plus de 110 %",
            .resetApproaching: "Rappel avant réinitialisation",
            .aboutSubtitle: "Calcul quotidien et estimation du rythme",
            .overview: "Aperçu",
            .expectedTodayRunout: "Heure d'épuisement moyenne",
            .systemQuotaStats: "Quota système brut",
            .noTodayRunout: "Ne s'épuisera pas aujourd'hui",
            .todayBudgetUsage: "Part du jour utilisée",
            .todayBudget: "Part du jour",
            .dailyAverageAlgorithm: "Formule moyenne quotidienne",
            .dailyAverageFormulaNote: "Recalculée après chaque actualisation. Moins utilisé aujourd'hui reporte du quota; trop utilisé réduit les budgets suivants.",
            .todayUsage: "Utilisation du jour",
            .todayBudgetDepleted: "Budget du jour épuisé",
            .runsOutAt: "Épuisé %@",
            .account: "Compte",
            .signOut: "Déconnexion",
            .authPrivacy: "Les jetons d'autorisation restent sur ce Mac et ne sont jamais envoyés.",
            .skippedDay: "Repos",
            .todayLabel: "Aujourd'hui",
            .officialQuotaPage: "Page officielle d'utilisation",
            .officialQuotaPageNote: "Ouvre la page officielle pour vérifier le quota restant; cet outil ne fait que des relevés locaux et une estimation quotidienne.",
            .appControls: "Application",
            .quitApp: "Quitter Codex Quota Calendar",
            .quitAppNote: "Quitte l'app de la barre de menus. Réouverture possible depuis Launchpad ou Applications.",
            .aboutTagline: "Transforme le quota Codex restant en rythme utilisable aujourd'hui.",
            .aboutLocalPromise: "Autorisation, journaux et bases quotidiennes restent sur ce Mac. Pas de proxy, d'envoi ni de changement de compte.",
            .aboutGithub: "GitHub",
            .aboutGithubNote: "Ouvre le profil de l'auteur. La page projet partira de là.",
            .aboutAuthorX: "X de l'auteur",
            .aboutAuthorXNote: "Ouvre le profil X de l'auteur pour les mises à jour et les retours.",
            .aboutEmail: "Email",
            .aboutSupportEmail: "zikedece@proton.me",
            .aboutEmailNote: "Envoyez vos retours sur le calcul, les réinitialisations ou l'interface.",
            .aboutLandingPage: "Page produit",
            .aboutLandingPageNote: "Une page GitHub Pages avec présentation, captures et guide arrivera plus tard.",
            .aboutVersion: "Version",
            .aboutUpdateSoftware: "Rechercher les mises à jour",
            .aboutUpdateSoftwareNote: "Ouvre GitHub Releases pour télécharger la dernière version.",
            .perWeekSuffix: "/sem",
            .perDaySuffix: "/jour",
            .dayUnit: "jours",
            .dailyAverageFormula: "%@ ÷ %d jours = %@/jour",
            .activeDaysRebalanced: "Recalculé sur %d jours disponibles",
            .usedPercentLabel: "%@ utilisé"
        ],
        .de: [
            .updatedAt: "Aktualisiert %@",
            .comfortablePace: "Angenehmer Takt",
            .noActiveBurnRate: "Keine aktive Verbrauchsrate",
            .appearance: "Darstellung",
            .refreshInterval: "Aktualisierung",
            .fiveMinutes: "5 Min.",
            .tenMinutes: "10 Min.",
            .fifteenMinutes: "15 Min.",
            .thirtyMinutes: "30 Min.",
            .oneHour: "1 Std.",
            .dailyLine: "Tageslinie",
            .overLine: "Über 110 %",
            .resetApproaching: "Reset-Erinnerung",
            .aboutSubtitle: "Tageskontingent und Taktprognose",
            .overview: "Übersicht",
            .expectedTodayRunout: "Prognose Tagesmittel leer",
            .systemQuotaStats: "System-Rohkontingent",
            .noTodayRunout: "Heute nicht leer",
            .todayBudgetUsage: "Tagesanteil genutzt",
            .todayBudget: "Tagesanteil",
            .dailyAverageAlgorithm: "Tagesdurchschnittsformel",
            .dailyAverageFormulaNote: "Wird nach jeder Aktualisierung neu berechnet. Weniger Nutzung heute bleibt später übrig; Mehrnutzung senkt die nächsten Tagesbudgets.",
            .todayUsage: "Heutige Nutzung",
            .todayBudgetDepleted: "Tagesbudget verbraucht",
            .runsOutAt: "Leer um %@",
            .account: "Konto",
            .signOut: "Abmelden",
            .authPrivacy: "Auth-Tokens werden nur auf diesem Mac gespeichert und nie hochgeladen.",
            .skippedDay: "Ruhetag",
            .todayLabel: "Heute",
            .officialQuotaPage: "Offizielle Nutzungsseite",
            .officialQuotaPageNote: "Öffnet die offizielle Seite zum Abgleich des Restkontingents; dieses Tool protokolliert lokal und schätzt den Tagesrhythmus.",
            .appControls: "Anwendung",
            .quitApp: "Codex Quota Calendar beenden",
            .quitAppNote: "Beendet die Menüleisten-App. Später über Launchpad oder Programme erneut öffnen.",
            .aboutTagline: "Macht aus verbleibender Codex-Quote den heutigen Nutzungsrhythmus.",
            .aboutLocalPromise: "Auth, Nutzungslogs und Tagesbasen bleiben auf diesem Mac. Kein Proxy, Upload oder Kontowechsel.",
            .aboutGithub: "GitHub",
            .aboutGithubNote: "Öffnet das Autorenprofil. Die Projektseite entsteht dort weiter.",
            .aboutAuthorX: "X des Autors",
            .aboutAuthorXNote: "Öffnet das X-Profil des Autors für Updates und Feedback.",
            .aboutEmail: "E-Mail",
            .aboutSupportEmail: "zikedece@proton.me",
            .aboutEmailNote: "Feedback zu Berechnung, Resets oder UI per E-Mail senden.",
            .aboutLandingPage: "Produktseite",
            .aboutLandingPageNote: "Eine GitHub-Pages-Seite mit Intro, Screenshots und Anleitung folgt später.",
            .aboutVersion: "Version",
            .aboutUpdateSoftware: "Nach Updates suchen",
            .aboutUpdateSoftwareNote: "Öffnet GitHub Releases zum Download der neuesten Version.",
            .perWeekSuffix: "/Woche",
            .perDaySuffix: "/Tag",
            .dayUnit: "Tage",
            .dailyAverageFormula: "%@ ÷ %d Tage = %@/Tag",
            .activeDaysRebalanced: "Auf %d verfügbare Tage neu verteilt",
            .usedPercentLabel: "%@ genutzt"
        ],
        .pt: [
            .updatedAt: "Atualizado %@",
            .comfortablePace: "Ritmo confortável",
            .noActiveBurnRate: "Sem velocidade ativa",
            .appearance: "Aparência",
            .refreshInterval: "Atualização",
            .fiveMinutes: "5 min",
            .tenMinutes: "10 min",
            .fifteenMinutes: "15 min",
            .thirtyMinutes: "30 min",
            .oneHour: "1 hora",
            .dailyLine: "Linha diária",
            .overLine: "Acima de 110%",
            .resetApproaching: "Aviso de restauração",
            .aboutSubtitle: "Cálculo diário e previsão de ritmo",
            .overview: "Visão geral",
            .expectedTodayRunout: "Hora estimada da média diária",
            .systemQuotaStats: "Cota original do sistema",
            .noTodayRunout: "Não acaba hoje",
            .todayBudgetUsage: "Uso da cota de hoje",
            .todayBudget: "Cota de hoje",
            .dailyAverageAlgorithm: "Fórmula média diária",
            .dailyAverageFormulaNote: "Recalculado após cada atualização. Usar menos hoje passa saldo adiante; usar mais reduz os próximos orçamentos diários.",
            .todayUsage: "Uso de hoje",
            .todayBudgetDepleted: "Orçamento de hoje usado",
            .runsOutAt: "Acaba %@",
            .account: "Conta",
            .signOut: "Sair",
            .authPrivacy: "Tokens de autorização ficam apenas neste Mac e nunca são enviados.",
            .skippedDay: "Descanso",
            .todayLabel: "Hoje",
            .officialQuotaPage: "Página oficial de uso",
            .officialQuotaPageNote: "Abre a página oficial para conferir a cota restante; este app só registra localmente e estima o ritmo diário.",
            .appControls: "Aplicativo",
            .quitApp: "Sair do Codex Quota Calendar",
            .quitAppNote: "Sai do app da barra de menus. Reabra depois pelo Launchpad ou Aplicativos.",
            .aboutTagline: "Transforma a cota restante do Codex no ritmo utilizável de hoje.",
            .aboutLocalPromise: "Autorização, logs e linhas base diárias ficam apenas neste Mac. Sem proxy, envio ou troca de conta.",
            .aboutGithub: "GitHub",
            .aboutGithubNote: "Abre o perfil do autor. A página do projeto crescerá a partir dali.",
            .aboutAuthorX: "X do autor",
            .aboutAuthorXNote: "Abre o perfil X do autor para atualizações e feedback.",
            .aboutEmail: "Email",
            .aboutSupportEmail: "zikedece@proton.me",
            .aboutEmailNote: "Envie feedback sobre cálculo, restaurações ou interface.",
            .aboutLandingPage: "Página do produto",
            .aboutLandingPageNote: "Uma página no GitHub Pages com introdução, capturas e guia virá depois.",
            .aboutVersion: "Versão",
            .aboutUpdateSoftware: "Verificar atualizações",
            .aboutUpdateSoftwareNote: "Abre o GitHub Releases para baixar a versão mais recente.",
            .perWeekSuffix: "/sem",
            .perDaySuffix: "/dia",
            .dayUnit: "dias",
            .dailyAverageFormula: "%@ ÷ %d dias = %@/dia",
            .activeDaysRebalanced: "Recalculado em %d dias disponíveis",
            .usedPercentLabel: "%@ usado"
        ],
        .it: [
            .updatedAt: "Aggiornato %@",
            .comfortablePace: "Ritmo comodo",
            .noActiveBurnRate: "Nessun consumo attivo",
            .appearance: "Aspetto",
            .refreshInterval: "Aggiornamento",
            .fiveMinutes: "5 min",
            .tenMinutes: "10 min",
            .fifteenMinutes: "15 min",
            .thirtyMinutes: "30 min",
            .oneHour: "1 ora",
            .dailyLine: "Linea giornaliera",
            .overLine: "Oltre 110%",
            .resetApproaching: "Promemoria reset",
            .aboutSubtitle: "Calcolo quota giornaliera e ritmo",
            .overview: "Panoramica",
            .expectedTodayRunout: "Fine stimata media giornaliera",
            .systemQuotaStats: "Quota originale di sistema",
            .noTodayRunout: "Non finirà oggi",
            .todayBudgetUsage: "Quota di oggi usata",
            .todayBudget: "Quota di oggi",
            .dailyAverageAlgorithm: "Formula media giornaliera",
            .dailyAverageFormulaNote: "Ricalcolata dopo ogni aggiornamento. Se oggi usi meno, resta per dopo; se usi troppo, riduce i budget successivi.",
            .todayUsage: "Uso di oggi",
            .todayBudgetDepleted: "Budget di oggi usato",
            .runsOutAt: "Finisce %@",
            .account: "Profilo",
            .signOut: "Esci",
            .authPrivacy: "I token restano solo su questo Mac e non vengono caricati.",
            .skippedDay: "Riposo",
            .todayLabel: "Oggi",
            .officialQuotaPage: "Pagina ufficiale uso",
            .officialQuotaPageNote: "Apre la pagina ufficiale per verificare la quota restante; questa app registra in locale e stima il ritmo giornaliero.",
            .appControls: "Applicazione",
            .quitApp: "Esci da Codex Quota Calendar",
            .quitAppNote: "Chiude l'app della barra dei menu. Puoi riaprirla da Launchpad o Applicazioni.",
            .aboutTagline: "Trasforma la quota Codex rimasta nel ritmo usabile di oggi.",
            .aboutLocalPromise: "Autorizzazione, log e basi giornaliere restano su questo Mac. Nessun proxy, upload o cambio account.",
            .aboutGithub: "GitHub",
            .aboutGithubNote: "Apre il profilo dell'autore. La pagina progetto crescerà da lì.",
            .aboutAuthorX: "X dell'autore",
            .aboutAuthorXNote: "Apre il profilo X dell'autore per aggiornamenti e feedback.",
            .aboutEmail: "Email",
            .aboutSupportEmail: "zikedece@proton.me",
            .aboutEmailNote: "Invia feedback su calcoli, reset o interfaccia.",
            .aboutLandingPage: "Pagina prodotto",
            .aboutLandingPageNote: "Arriverà una pagina GitHub Pages con introduzione, screenshot e guida.",
            .aboutVersion: "Versione",
            .aboutUpdateSoftware: "Cerca aggiornamenti",
            .aboutUpdateSoftwareNote: "Apre GitHub Releases per scaricare l'ultima versione.",
            .perWeekSuffix: "/sett",
            .perDaySuffix: "/giorno",
            .dayUnit: "giorni",
            .dailyAverageFormula: "%@ ÷ %d giorni = %@/giorno",
            .activeDaysRebalanced: "Ricalcolato su %d giorni disponibili",
            .usedPercentLabel: "%@ usato"
        ],
        .id: [
            .updatedAt: "Diperbarui %@",
            .comfortablePace: "Ritme nyaman",
            .noActiveBurnRate: "Belum ada laju penggunaan",
            .appearance: "Tampilan",
            .refreshInterval: "Frekuensi segar",
            .fiveMinutes: "5 mnt",
            .tenMinutes: "10 mnt",
            .fifteenMinutes: "15 mnt",
            .thirtyMinutes: "30 mnt",
            .oneHour: "1 jam",
            .dailyLine: "Batas harian",
            .overLine: "Lebih dari 110%",
            .resetApproaching: "Pengingat reset",
            .aboutSubtitle: "Kalkulasi kuota harian dan ritme",
            .overview: "Ringkasan",
            .expectedTodayRunout: "Perkiraan habis rata-rata harian",
            .systemQuotaStats: "Kuota asli sistem",
            .noTodayRunout: "Tidak habis hari ini",
            .todayBudgetUsage: "Jatah hari ini terpakai",
            .todayBudget: "Jatah hari ini",
            .dailyAverageAlgorithm: "Rumus rata-rata harian",
            .dailyAverageFormulaNote: "Dihitung ulang setelah tiap penyegaran. Kurang pakai hari ini dibawa ke hari berikutnya; lebih pakai mengurangi anggaran berikutnya.",
            .todayUsage: "Penggunaan hari ini",
            .todayBudgetDepleted: "Anggaran hari ini habis",
            .runsOutAt: "Habis %@",
            .account: "Akun",
            .signOut: "Keluar",
            .authPrivacy: "Token otorisasi hanya disimpan di Mac ini dan tidak pernah diunggah.",
            .skippedDay: "Istirahat",
            .todayLabel: "Hari ini",
            .officialQuotaPage: "Halaman penggunaan resmi",
            .officialQuotaPageNote: "Buka halaman resmi untuk memeriksa sisa kuota; alat ini hanya mencatat lokal dan memperkirakan ritme harian.",
            .appControls: "Aplikasi",
            .quitApp: "Keluar dari Codex Quota Calendar",
            .quitAppNote: "Keluar dari aplikasi menu bar. Buka lagi nanti dari Launchpad atau Applications.",
            .aboutTagline: "Ubah sisa kuota Codex menjadi ritme yang bisa dipakai hari ini.",
            .aboutLocalPromise: "Otorisasi, log penggunaan, dan baseline harian hanya disimpan di Mac ini. Tanpa proxy, unggahan, atau ganti akun.",
            .aboutGithub: "GitHub",
            .aboutGithubNote: "Buka profil pembuat. Halaman proyek akan berkembang dari sana.",
            .aboutAuthorX: "X pembuat",
            .aboutAuthorXNote: "Buka profil X pembuat untuk pembaruan dan masukan.",
            .aboutEmail: "Email",
            .aboutSupportEmail: "zikedece@proton.me",
            .aboutEmailNote: "Kirim masukan soal perhitungan, reset, atau UI.",
            .aboutLandingPage: "Halaman produk",
            .aboutLandingPageNote: "Halaman GitHub Pages berisi intro, tangkapan layar, dan panduan akan hadir nanti.",
            .aboutVersion: "Versi",
            .aboutUpdateSoftware: "Periksa pembaruan",
            .aboutUpdateSoftwareNote: "Buka GitHub Releases untuk mengunduh versi terbaru.",
            .perWeekSuffix: "/minggu",
            .perDaySuffix: "/hari",
            .dayUnit: "hari",
            .dailyAverageFormula: "%@ ÷ %d hari = %@/hari",
            .activeDaysRebalanced: "Dihitung ulang untuk %d hari tersedia",
            .usedPercentLabel: "Terpakai %@"
        ],
        .th: [
            .updatedAt: "อัปเดต %@",
            .comfortablePace: "จังหวะสบาย",
            .noActiveBurnRate: "ยังไม่มีอัตราการใช้",
            .appearance: "ลักษณะ",
            .refreshInterval: "ความถี่รีเฟรช",
            .fiveMinutes: "5 นาที",
            .tenMinutes: "10 นาที",
            .fifteenMinutes: "15 นาที",
            .thirtyMinutes: "30 นาที",
            .oneHour: "1 ชั่วโมง",
            .dailyLine: "เส้นวันนี้",
            .overLine: "เกิน 110%",
            .resetApproaching: "เตือนก่อนรีเซ็ต",
            .aboutSubtitle: "คำนวณโควตารายวันและคาดจังหวะ",
            .overview: "ภาพรวม",
            .expectedTodayRunout: "เวลาคาดว่าจะหมดตามค่าเฉลี่ยวันนี้",
            .systemQuotaStats: "โควตาดิบของระบบ",
            .noTodayRunout: "วันนี้จะยังไม่หมด",
            .todayBudgetUsage: "ใช้ส่วนของวันนี้แล้ว",
            .todayBudget: "ส่วนของวันนี้",
            .dailyAverageAlgorithm: "สูตรเฉลี่ยรายวัน",
            .dailyAverageFormulaNote: "คำนวณใหม่หลังรีเฟรชทุกครั้ง ใช้น้อยวันนี้จะเหลือให้วันถัดไป ใช้เกินวันนี้จะลดงบวันต่อ ๆ ไป",
            .todayUsage: "การใช้วันนี้",
            .todayBudgetDepleted: "ใช้งบวันนี้หมดแล้ว",
            .runsOutAt: "หมด %@",
            .account: "บัญชี",
            .signOut: "ออกจากระบบ",
            .authPrivacy: "โทเค็นอนุญาตเก็บไว้เฉพาะบน Mac เครื่องนี้และไม่อัปโหลด",
            .skippedDay: "พัก",
            .todayLabel: "วันนี้",
            .officialQuotaPage: "หน้าการใช้งานทางการ",
            .officialQuotaPageNote: "เปิดหน้าทางการเพื่อตรวจสอบโควตาที่เหลือ เครื่องมือนี้บันทึกในเครื่องและประเมินจังหวะรายวันเท่านั้น",
            .appControls: "แอป",
            .quitApp: "ปิด Codex Quota Calendar",
            .quitAppNote: "ออกจากแอปแถบเมนู เปิดใหม่ได้จาก Launchpad หรือ Applications",
            .aboutTagline: "แปลงโควตา Codex ที่เหลือเป็นจังหวะที่ใช้ได้วันนี้",
            .aboutLocalPromise: "การอนุญาต บันทึกการใช้ และเส้นฐานรายวันเก็บไว้บน Mac เครื่องนี้เท่านั้น ไม่มีพร็อกซี ไม่อัปโหลด ไม่สลับบัญชี",
            .aboutGithub: "GitHub",
            .aboutGithubNote: "เปิดโปรไฟล์ผู้สร้าง หน้าโปรเจกต์จะต่อยอดจากที่นี่",
            .aboutAuthorX: "X ของผู้สร้าง",
            .aboutAuthorXNote: "เปิดโปรไฟล์ X ของผู้สร้างเพื่อติดตามอัปเดตและส่งฟีดแบ็ก",
            .aboutEmail: "อีเมล",
            .aboutSupportEmail: "zikedece@proton.me",
            .aboutEmailNote: "ส่งข้อเสนอแนะเรื่องการคำนวณ รีเซ็ต หรือ UI",
            .aboutLandingPage: "หน้าผลิตภัณฑ์",
            .aboutLandingPageNote: "ภายหลังจะมีหน้า GitHub Pages พร้อมคำแนะนำ ภาพหน้าจอ และคู่มือ",
            .aboutVersion: "เวอร์ชัน",
            .aboutUpdateSoftware: "ตรวจสอบอัปเดต",
            .aboutUpdateSoftwareNote: "เปิด GitHub Releases เพื่อดาวน์โหลดเวอร์ชันล่าสุด",
            .perWeekSuffix: "/สัปดาห์",
            .perDaySuffix: "/วัน",
            .dayUnit: "วัน",
            .dailyAverageFormula: "%@ ÷ %d วัน = %@/วัน",
            .activeDaysRebalanced: "คำนวณใหม่ตาม %d วันที่ใช้ได้",
            .usedPercentLabel: "ใช้แล้ว %@"
        ]
    ]

    private static func base(
        appName: String,
        todayStatus: String,
        weeklyCycle: String,
        predictedExhaustion: String,
        settings: String,
        about: String,
        appearanceDay: String,
        appearanceNight: String,
        appearanceSystem: String,
        language: String,
        refreshNow: String,
        privacySummary: String,
        fiveHourWindow: String,
        weeklyWindow: String,
        sevenDayPacing: String,
        monthlyHeatmap: String,
        notifications: String,
        aboutBody: String
    ) -> [LocalizedKey: String] {
        [
            .appName: appName,
            .todayStatus: todayStatus,
            .weeklyCycle: weeklyCycle,
            .predictedExhaustion: predictedExhaustion,
            .settings: settings,
            .about: about,
            .appearanceDay: appearanceDay,
            .appearanceNight: appearanceNight,
            .appearanceSystem: appearanceSystem,
            .language: language,
            .refreshNow: refreshNow,
            .privacySummary: privacySummary,
            .fiveHourWindow: fiveHourWindow,
            .weeklyWindow: weeklyWindow,
            .sevenDayPacing: sevenDayPacing,
            .monthlyHeatmap: monthlyHeatmap,
            .notifications: notifications,
            .aboutBody: aboutBody
        ]
    }
}
