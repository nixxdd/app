// HomeMedsSection.swift
import SwiftUI

struct HomeMedsSection: View {
    let daySectionTitle: String
    let progress: (taken: Int, total: Int)
    let activeMeds: [Medicine]
    let pilbyMood: AvatarSentiment
    let date: Date
    let onScanTapped: () -> Void

    @State private var showCards = false
    @State private var showEmptyState = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerRow
            if progress.total > 0 { progressBar }
            contentSection
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .transition(.opacity)
    }

    private var headerRow: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(daySectionTitle)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color.navy)
                    .tracking(-0.3)

                if progress.total > 0 {
                    Text(progress.taken == progress.total
                         ? "All doses completed"
                         : "\(progress.total - progress.taken) left today")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text(progress.total == 0 ? "–" : "\(progress.taken)/\(progress.total)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(progressTextColor)
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)

                RoundedRectangle(cornerRadius: 2)
                    .fill(progressFillStyle)
                    .frame(
                        width: geo.size.width * CGFloat(progress.taken) / CGFloat(progress.total),
                        height: 4
                    )
                    .animation(.spring(response: 0.45, dampingFraction: 0.85), value: progress.taken)
            }
        }
        .frame(height: 4)
    }

    @ViewBuilder
    private var contentSection: some View {
        if activeMeds.isEmpty {
            emptyState
        } else {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(Array(activeMeds.enumerated()), id: \.element.id) { index, med in
                        HomeMedCard(medicine: med, date: date)  
                            .opacity(showCards ? 1 : 0)
                            .offset(y: showCards ? 0 : 12)
                            .animation(
                                .spring(response: 0.45, dampingFraction: 0.82)
                                    .delay(Double(index) * 0.04),
                                value: showCards
                            )
                    }
                }
                .padding(.top, 2)
                .padding(.bottom, 18)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onAppear { showCards = true }
            .onChange(of: activeMeds.count) { _, _ in
                showCards = false
                withAnimation(.easeOut(duration: 0.2)) { showCards = true }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer(minLength: 12)

            Image(systemName: "pill.fill")              
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(Color.violet.opacity(0.3))

            Text("No medicines for this day.")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color.navy)

            Text("Tap + to add one")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 12)
        .opacity(showEmptyState ? 1 : 0)
        .offset(y: showEmptyState ? 0 : 10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.35)) { showEmptyState = true }
        }
    }

    private var progressTextColor: Color {
        progress.taken == progress.total && progress.total > 0
            ? Color.green
            : Color.violet
    }

    private var progressFillStyle: AnyShapeStyle {
        if progress.taken == progress.total {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.green, Color.green.opacity(0.6)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        } else {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.violet, Color.violet.opacity(0.6)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }
}
