//
//  NFCSetupView.swift
//  app
//
//  Created by Foundation 34 on 10/03/26.
//

import SwiftUI

struct NFCSetupView: View {
    let medicineName: String         
    @StateObject private var writer = NFCWriter()
    @State private var tagWritten = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {

                // Title
                VStack(spacing: 6) {
                    Text("Set up NFC Tag")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .tracking(-0.4)
                    Text("Stick a tag on your pill bottle, then tap below to write.")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 12)

                // Medicine name preview
                HStack(spacing: 14) {
                    Image(systemName: "wave.3.right.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color.violet)
                        .frame(width: 48, height: 48)
                        .background(Color.violet.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tag will store")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        Text(medicineName.isEmpty ? "Medicine name" : medicineName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.navy)
                    }
                    Spacer()
                }
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)

                // How it works steps
                stepsCard

                // Success banner
                if tagWritten {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.12))
                                .frame(width: 36, height: 36)
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color.green)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Tag written!")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.navy)
                            Text("Hold this tag near your phone to confirm doses.")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(Color.green.opacity(0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.green.opacity(0.25), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Error banner
                if writer.showAlert && !writer.alertMessage.contains("Success") {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(writer.alertMessage)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                    }
                    .padding(14)
                    .background(Color.red.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Write button
                Button {
                    tagWritten = false
                    writer.showAlert = false
                    writer.write(text: medicineName)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .font(.system(size: 16))
                        Text(tagWritten ? "Write Again" : "Write to Tag")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(
                            colors: [Color.violet, Color.violet.opacity(0.7)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .disabled(medicineName.isEmpty)

            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        // listen for success from the writer
        .onChange(of: writer.alertMessage) { _, msg in
            if msg.contains("Success") {
                withAnimation { tagWritten = true }
            }
        }
    }

    private var stepsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("How It Works")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 10)

            Divider().padding(.horizontal, 16)

            stepRow("1", Color.violet,
                    "Stick an NFC sticker on your pill bottle or packaging")
            Divider().padding(.leading, 52)
            stepRow("2", Color.green,
                    "Tap \"Write to Tag\" and hold iPhone near the sticker")
            Divider().padding(.leading, 52)
            stepRow("3", Color.amber,
                    "Later, scan the tag to instantly mark your dose as taken")
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func stepRow(_ step: String, _ color: Color, _ text: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 26, height: 26)
                Text(step)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(color)
            }
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
