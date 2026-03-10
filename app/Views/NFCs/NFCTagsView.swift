//
//  NFCTagsView.swift
//  app
//
//  Created by Foundation 34 on 10/03/26.
//

import SwiftUI
import SwiftData

struct NFCTagsView: View {
    @Query var medicines: [Medicine]
    @StateObject private var reader = NFCReader()
    @State private var lastScannedName: String? = nil
    @State private var scannedMedicine: Medicine? = nil
    @State private var showScanResult = false

    // only medicines with NFC enabled
    private var nfcMedicines: [Medicine] {
        medicines.filter { $0.nfcEnabled }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.lightgray.ignoresSafeArea()

                VStack(spacing: 0) {
                    customHeader

                    if nfcMedicines.isEmpty {
                        emptyState
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 14) {
                                ForEach(nfcMedicines) { med in
                                    NFCTagCard(medicine: med)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
        }
        // when reader detects a tag name, find the matching medicine
        .onChange(of: reader.lastScannedMedicineName) { _, name in
            guard let name = name else { return }
            scannedMedicine = medicines.first {
                $0.medName.lowercased() == name.lowercased() && $0.nfcEnabled
            }
            showScanResult = true
            reader.lastScannedMedicineName = nil
        }
        // result sheet
        .sheet(isPresented: $showScanResult) {
            NFCScanResultView(medicine: scannedMedicine)
        }
    }

    private var customHeader: some View {
        HStack {
            Text("NFC Tags")
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundColor(Color.navy)
                .frame(maxWidth: .infinity, alignment: .center)
                .overlay(alignment: .trailing) {
                    Button {
                        reader.scan()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "wave.3.right.circle.fill")
                            Text("Scan")
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.violet)
                        .clipShape(Capsule())
                        .shadow(radius: 4)
                    }
                }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "wave.3.right.circle")
                .font(.system(size: 48))
                .foregroundColor(Color.violet.opacity(0.3))
            Text("No NFC tags set up")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color.navy)
            Text("Enable NFC when adding a medicine\nto set up a tag.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
}

// MARK: - NFC Tag Card
struct NFCTagCard: View {
    let medicine: Medicine
    @StateObject private var writer = NFCWriter()
    @State private var rewritten = false

    var body: some View {
        HStack(spacing: 14) {
            // icon
            Image(systemName: medicine.iconName)
                .font(.system(size: 20))
                .foregroundColor(MedIcon.color(for: medicine.iconName))
                .frame(width: 48, height: 48)
                .background(MedIcon.color(for: medicine.iconName).opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 4) {
                Text(medicine.medName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.navy)

                HStack(spacing: 6) {
                    Image(systemName: "wave.3.right.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color.violet)
                    Text("NFC enabled")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.violet)
                }

                if rewritten {
                    Text("Tag rewritten")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color.lime)
                }
            }

            Spacer()

            // rewrite button
            Button {
                rewritten = false
                writer.write(text: medicine.medName)
            } label: {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color.violet.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        .onChange(of: writer.alertMessage) { _, msg in
            if msg.contains("Success") {
                withAnimation { rewritten = true }
            }
        }
        .alert(writer.alertMessage, isPresented: $writer.showAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}

// MARK: - Scan Result Sheet
struct NFCScanResultView: View {
    @Environment(\.dismiss) private var dismiss
    let medicine: Medicine?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            if let med = medicine {
                // found a matching medicine
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color.lime)

                    Text("Dose logged!")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(Color.navy)

                    Text(med.medName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .onAppear {
                    // mark as taken when this sheet appears
                    med.markAsTaken()
                }
            } else {
                // no matching medicine found
                VStack(spacing: 16) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color.amber)

                    Text("Tag not recognised")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(Color.navy)

                    Text("This tag isn't linked to any medicine.\nMake sure NFC is enabled when saving.")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            Spacer()

            Button { dismiss() } label: {
                Text("Done")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.violet)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .presentationDetents([.medium])
    }
}
