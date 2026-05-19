//
//  SettingsView.swift
//  BobPT
//
//  Created by Codex on 5/19/26.
//

import MessageUI
import SwiftUI
import BobPTDomain
import DesignSystem

struct SettingsView: View {
    @AppStorage(DesignSystem.AppearanceMode.storageKey) private var appearanceMode = DesignSystem.AppearanceMode.system
    @State private var showsMailComposer = false
    @State private var opensMailSettingsAlert = false

    var body: some View {
        List {
            Picker("화면 모드", selection: $appearanceMode) {
                ForEach(DesignSystem.AppearanceMode.allCases) { mode in
                    Text(mode.title)
                        .tag(mode)
                }
            }
            .pickerStyle(.menu)
            .listRowBackground(DesignSystem.Colors.surface)

            HStack {
                Text("버전")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
            }
            .listRowBackground(DesignSystem.Colors.surface)

            NavigationLink {
                DeveloperView()
            } label: {
                Text("개발자 정보")
            }
            .listRowBackground(DesignSystem.Colors.surface)

            Button {
                if MFMailComposeViewController.canSendMail() {
                    showsMailComposer = true
                } else {
                    opensMailSettingsAlert = true
                }
            } label: {
                Text("건의사항")
                    .foregroundStyle(DesignSystem.Colors.text)
            }
            .listRowBackground(DesignSystem.Colors.surface)
        }
        .scrollContentBackground(.hidden)
        .background(DesignSystem.Colors.background)
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showsMailComposer) {
            MailComposeView()
        }
        .alert("메일 계정을 설정해주세요", isPresented: $opensMailSettingsAlert) {
            Button("확인", role: .cancel) {}
        }
    }
}

struct DeveloperView: View {
    var body: some View {
        List(DeveloperProfile.all) { developer in
            HStack(spacing: 14) {
                AsyncImage(url: developer.avatarURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        DesignSystem.Colors.selectedSurface
                    }
                }
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    Text(developer.name)
                        .font(.headline)
                    Link(developer.githubURL.absoluteString, destination: developer.githubURL)
                        .font(.subheadline)
                }
            }
            .padding(.vertical, 6)
            .listRowBackground(DesignSystem.Colors.surface)
        }
        .scrollContentBackground(.hidden)
        .background(DesignSystem.Colors.background)
        .navigationTitle("개발자 정보")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MailComposeView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = context.coordinator
        mail.setToRecipients(["sea15510@icloud.com"])
        mail.setSubject("앱 건의사항")
        mail.setMessageBody("<p>여기에 건의사항을 입력해 주세요.</p>", isHTML: true)
        return mail
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        private let dismiss: DismissAction

        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            dismiss()
        }
    }
}
