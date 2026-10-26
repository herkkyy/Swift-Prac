import SwiftUI

// MARK: - 1. Model Data (Clean & Identifiable)
enum HabitCategory: String, CaseIterable, Codable {
    case fitness = "Fitness"
    case focus = "Belajar"
    case mindfulness = "Kesehatan"
    case routine = "Rutinitas"
    
    var icon: String {
        switch self {
        case .fitness: return "figure.run"
        case .focus: return "book.fill"
        case .mindfulness: return "heart.fill"
        case .routine: return "cup.and.saucer.fill"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .fitness: return Color.orange
        case .focus: return Color.indigo
        case .mindfulness: return Color.pink
        case .routine: return Color.teal
        }
    }
}

struct HabitItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var category: HabitCategory
    var streakCount: Int = 0
    var isCompletedToday: Bool = false
}

// MARK: - 2. UI View
struct ContentView: View {
    // @State: Menyimpan state/data dinamis di Swift
    @State private var habits: [HabitItem] = [
        HabitItem(title: "Belajar Swift 30 Menit", category: .focus, streakCount: 3, isCompletedToday: true),
        HabitItem(title: "Minum Air 2 Liter", category: .mindfulness, streakCount: 5, isCompletedToday: false),
        HabitItem(title: "Push-up 20x", category: .fitness, streakCount: 1, isCompletedToday: false),
        HabitItem(title: "Baca Buku 1 Bab", category: .focus, streakCount: 7, isCompletedToday: true)
    ]
    
    @State private var newHabitTitle: String = ""
    @State private var selectedCategory: HabitCategory = .focus
    @State private var showAddSheet: Bool = false
    
    private var completedPercentage: Double {
        guard !habits.isEmpty else { return 0 }
        let completed = habits.filter { $0.isCompletedToday }.count
        return Double(completed) / Double(habits.count)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradasi modern cross-platform (iOS & macOS)
                #if os(iOS)
                LinearGradient(
                    colors: [Color(uiColor: .systemGroupedBackground), Color(uiColor: .secondarySystemGroupedBackground)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                #else
                LinearGradient(
                    colors: [Color(nsColor: .windowBackgroundColor), Color(nsColor: .underPageBackgroundColor)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                #endif

                ScrollView {
                    VStack(spacing: 20) {
                        // Header Progress Card
                        progressHeroCard
                        
                        // Habit List Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Target Hari Ini")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)
                            
                            ForEach($habits) { $habit in
                                HabitRowCard(habit: $habit)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Habit Flow")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.indigo)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                addHabitSheet
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Subviews (Clean Code: Modular & Readable)
    private var progressHeroCard: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Progres Harian")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.8))
                
                Text("\(Int(completedPercentage * 100))%")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("\(habits.filter { $0.isCompletedToday }.count) dari \(habits.count) habit selesai")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.85))
            }
            
            Spacer()
            
            // Circular Ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: completedPercentage)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: completedPercentage)
            }
            .frame(width: 65, height: 65)
        }
        .padding(22)
        .background(
            LinearGradient(
                colors: [Color.indigo, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.indigo.opacity(0.3), radius: 15, x: 0, y: 10)
    }

    private var addHabitSheet: some View {
        NavigationStack {
            Form {
                Section("Detail Habit") {
                    TextField("Contoh: Meditasi 10 Menit", text: $newHabitTitle)
                    
                    Picker("Kategori", selection: $selectedCategory) {
                        ForEach(HabitCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                }
            }
            .navigationTitle("Habit Baru")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { showAddSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        if !newHabitTitle.isEmpty {
                            habits.append(
                                HabitItem(title: newHabitTitle, category: selectedCategory)
                            )
                            newHabitTitle = ""
                            showAddSheet = false
                        }
                    }
                    .disabled(newHabitTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Row Component (Ultra Clean & Interactive)
struct HabitRowCard: View {
    @Binding var habit: HabitItem
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Category
            Image(systemName: habit.category.icon)
                .font(.title3)
                .foregroundStyle(habit.category.accentColor)
                .frame(width: 44, height: 44)
                .background(habit.category.accentColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .strikethrough(habit.isCompletedToday, color: .secondary)
                    .foregroundStyle(habit.isCompletedToday ? .secondary : .primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text("\(habit.streakCount) hari beruntun")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Completion Toggle Button
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                    habit.isCompletedToday.toggle()
                    if habit.isCompletedToday {
                        habit.streakCount += 1
                    } else {
                        habit.streakCount = max(0, habit.streakCount - 1)
                    }
                }
            } label: {
                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(habit.isCompletedToday ? Color.green : Color.gray.opacity(0.35))
            }
            .buttonStyle(.plain)
        }
        .padding()
        #if os(iOS)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        #else
        .background(Color(nsColor: .controlBackgroundColor))
        #endif
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
    }
}

#Preview {
    ContentView()
}

