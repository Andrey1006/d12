import SwiftUI
import PhotosUI

struct CreateLetterView: View {
    @ObservedObject var viewModel: LettersViewModel
    let editing: Letter?

    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var recipient: String
    @State private var message: String
    @State private var unlockAt: Date
    @State private var accent: LetterAccent
    @State private var category: LetterCategory

    @State private var image: UIImage?
    @State private var photoItem: PhotosPickerItem?
    @State private var showingCamera = false

    init(viewModel: LettersViewModel, editing: Letter? = nil) {
        self.viewModel = viewModel
        self.editing = editing
        let fallback = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        _title = State(initialValue: editing?.title ?? "")
        _recipient = State(initialValue: editing?.recipient ?? "Future Me")
        _message = State(initialValue: editing?.message ?? "")
        _unlockAt = State(initialValue: editing?.unlockAt ?? fallback)
        _accent = State(initialValue: editing?.accent ?? .amber)
        _category = State(initialValue: editing?.category ?? .personal)
        if let data = editing?.photoData {
            _image = State(initialValue: UIImage(data: data))
        } else {
            _image = State(initialValue: nil)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    field(title: "Title") {
                        TextField("", text: $title, prompt: Text("Birthday in a year").foregroundColor(AppTheme.textSecondary))
                            .styledInput()
                    }

                    field(title: "Recipient") {
                        TextField("", text: $recipient)
                            .styledInput()
                    }

                    field(title: "Message") {
                        TextEditor(text: $message)
                            .frame(height: 140)
                            .scrollContentBackground(.hidden)
                            .padding(10)
                            .foregroundColor(AppTheme.textPrimary)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.cornerMedium, style: .continuous)
                                    .fill(AppTheme.surface)
                            )
                    }

                    field(title: "Photo (optional)") {
                        photoSection
                    }

                    field(title: "Category") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(LetterCategory.allCases) { option in
                                    categoryChip(option)
                                }
                            }
                        }
                    }

                    field(title: "Unlock date") {
                        DatePicker("", selection: $unlockAt, in: Date()..., displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .tint(AppTheme.accent)
                    }

                    field(title: "Color") {
                        HStack(spacing: 12) {
                            ForEach(LetterAccent.allCases) { option in
                                Circle()
                                    .fill(option.gradient)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle().stroke(Color.white, lineWidth: accent == option ? 3 : 0)
                                    )
                                    .onTapGesture { accent = option }
                            }
                        }
                    }

                    PrimaryButton(title: editing == nil ? "Seal Letter" : "Save Changes", action: save)
                        .disabled(title.isEmpty)
                        .opacity(title.isEmpty ? 0.5 : 1)
                        .padding(.top, 6)
                }
                .padding(20)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle(editing == nil ? "New Letter" : "Edit Letter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .onChange(of: photoItem) { newItem in
                loadPickedPhoto(newItem)
            }
            .sheet(isPresented: $showingCamera) {
                CameraPicker { picked in
                    image = picked
                    photoItem = nil
                }
                .ignoresSafeArea()
            }
        }
    }

    @ViewBuilder
    private var photoSection: some View {
        VStack(spacing: 12) {
            if let image {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerMedium, style: .continuous))

                    Button {
                        self.image = nil
                        photoItem = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .shadow(radius: 3)
                            .padding(8)
                    }
                }
            }

            HStack(spacing: 12) {
                PhotosPicker(selection: $photoItem, matching: .images) {
                    photoChip(icon: "photo.on.rectangle", title: "Gallery")
                }

                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button {
                        showingCamera = true
                    } label: {
                        photoChip(icon: "camera.fill", title: "Camera")
                    }
                }
            }
        }
    }

    private func categoryChip(_ option: LetterCategory) -> some View {
        let selected = category == option
        return Button {
            category = option
            Haptics.selection()
        } label: {
            HStack(spacing: 7) {
                Image(systemName: option.icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(option.title)
                    .font(.rounded(14, .semibold))
            }
            .foregroundColor(selected ? .white : AppTheme.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule().fill(selected ? AppTheme.accent : AppTheme.surface)
            )
        }
    }

    private func photoChip(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
            Text(title)
                .font(.rounded(15, .semibold))
        }
        .foregroundColor(AppTheme.textPrimary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerMedium, style: .continuous)
                .fill(AppTheme.surface)
        )
    }

    private func field<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.rounded(14, .semibold))
                .foregroundColor(AppTheme.textSecondary)
            content()
        }
    }

    private func loadPickedPhoto(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let loaded = UIImage(data: data) {
                image = loaded
            }
        }
    }

    private func save() {
        let cleanRecipient = recipient.isEmpty ? "Future Me" : recipient
        let photoData = image?.compressedData()
        Haptics.impact()

        if let editing {
            let updated = Letter(id: editing.id,
                                 title: title,
                                 recipient: cleanRecipient,
                                 message: message,
                                 createdAt: editing.createdAt,
                                 unlockAt: unlockAt,
                                 accent: accent,
                                 isOpened: editing.isOpened,
                                 photoData: photoData,
                                 category: category,
                                 isFavorite: editing.isFavorite)
            viewModel.update(updated)
        } else {
            let letter = Letter(title: title,
                                recipient: cleanRecipient,
                                message: message,
                                unlockAt: unlockAt,
                                accent: accent,
                                photoData: photoData,
                                category: category)
            viewModel.add(letter)
        }
        dismiss()
    }
}

private extension View {
    func styledInput() -> some View {
        self
            .font(.rounded(16, .regular))
            .foregroundColor(AppTheme.textPrimary)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerMedium, style: .continuous)
                    .fill(AppTheme.surface)
            )
    }
}
