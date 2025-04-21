//  DisplayView.swift
//  StikJIT
//
//  Created by neoarz on 4/9/25.

import SwiftUI

struct AccentColorPicker: View {
    @Binding var selectedColor: Color
    
    let colors: [Color] = [
        .blue,  // Default system blue
        .init(hex: "#7FFFD4")!, // Aqua
        .init(hex: "#50C878")!, // Green
        .red,   // Red
        .init(hex: "#6A5ACD")!, // Purple
        .init(hex: "#DA70D6")!, // Pink
        .white, // white
        .black // black
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Accent Color")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 12), count: 9), spacing: 12) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                        )
                        .overlay(
                            Circle()
                                .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                }
                
                // Direct Color Picker Circle
                ColorPicker("", selection: $selectedColor)
                    .labelsHidden()
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                    )
                    .clipShape(Circle())
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 12)
    }
}

struct DisplayView: View {
    @AppStorage("username") private var username = "User"
    @AppStorage("customAccentColor") private var customAccentColorHex: String = ""
    @AppStorage("appTheme") private var appTheme: String = "system"
    @AppStorage("loadAppIconsOnJIT") private var loadAppIconsOnJIT = true
    @AppStorage("useGlassTabBar") private var useGlassTabBar = false
    @AppStorage("useGradientBackground") private var useGradientBackground = false
    @State private var selectedAccentColor: Color = .blue
    @Environment(\.colorScheme) private var colorScheme
    
    private var accentColor: Color {
        if customAccentColorHex.isEmpty {
            return .blue
        } else {
            return Color(hex: customAccentColorHex) ?? .blue
        }
    }
    
    var body: some View {
        ZStack {
            // Background - either gradient or solid color based on preference
            if useGradientBackground {
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? Color.black : Color(hex: "#F2F4F6") ?? .white,
                        colorScheme == .dark ? Color(hex: "#212529") ?? .black : Color.white
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            } else {
                Color(colorScheme == .dark ? .black : UIColor.systemBackground)
                    .ignoresSafeArea()
            }
                
            ScrollView {
                VStack(spacing: 16) {
                    // App Theme Section with Accent Colors
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Theme")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding(.bottom, 4)
                        
                        // Theme selector with preview images
                        HStack(spacing: 12) {
                            // Automatic Theme
                            ThemeOptionButton(
                                title: "Automatic",
                                imageName: "System",
                                isSelected: appTheme == "system",
                                accentColor: selectedAccentColor,
                                action: { appTheme = "system" }
                            )
                            
                            // Light Theme
                            ThemeOptionButton(
                                title: "Light",
                                imageName: "LightUI",
                                isSelected: appTheme == "light",
                                accentColor: selectedAccentColor,
                                action: { appTheme = "light" }
                            )
                            
                            // Dark Theme
                            ThemeOptionButton(
                                title: "Dark",
                                imageName: "DarkUI",
                                isSelected: appTheme == "dark",
                                accentColor: selectedAccentColor,
                                action: { appTheme = "dark" }
                            )
                        }
                        .onChange(of: appTheme) { newValue in
                            applyTheme(newValue)
                        }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        // Accent Color Picker
                        AccentColorPicker(selectedColor: Binding(
                            get: { selectedAccentColor },
                            set: { newColor in
                                selectedAccentColor = newColor
                                saveCustomAccentColor(newColor)
                            }
                        ))
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(16)
                    
                    // Username Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Username")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        HStack {
                            TextField("Username", text: $username)
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding(.vertical, 8)
                            
                            if !username.isEmpty {
                                Button(action: { username = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color(UIColor.tertiaryLabel))
                                        .font(.system(size: 16))
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .background(Color(UIColor.tertiarySystemFill))
                        .cornerRadius(8)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(16)
                    
                    // JIT Options Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("App List")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Toggle("Load App Icons when Enabling JIT", isOn: $loadAppIconsOnJIT)
                                .foregroundColor(.primary)
                                .tint(.green)
                            
                            Text("Disabling this will hide app icons in the app list and may improve performance, while also giving it a more minimalistic look.")
                                .font(.footnote)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(16)
                    
                    // UI Options Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("UI Options")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 14) {
                            // Glass tab bar toggle
                            VStack(alignment: .leading, spacing: 6) {
                                Toggle("Use Glass Tab Bar", isOn: $useGlassTabBar)
                                    .foregroundColor(.primary)
                                    .tint(.green)
                                
                                Text("Enables the modern glass effect tab bar instead of using the standard system tab bar. Requires app restart to take effect.")
                                    .font(.footnote)
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                            
                            // Gradient background toggle
                            VStack(alignment: .leading, spacing: 6) {
                                Toggle("Use Gradient Background", isOn: $useGradientBackground)
                                    .foregroundColor(.primary)
                                    .tint(.green)
                                
                                Text("Enables a subtle gradient background instead of a solid color for a more modern look.")
                                    .font(.footnote)
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(16)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
        }
        .navigationTitle("Display")
        .onAppear {
            loadCustomAccentColor()
            applyTheme(appTheme)
        }
    }
    
    private func loadCustomAccentColor() {
        if customAccentColorHex.isEmpty {
            selectedAccentColor = .blue
        } else {
            selectedAccentColor = Color(hex: customAccentColorHex) ?? .blue
        }
    }
    
    private func saveCustomAccentColor(_ color: Color) {
        // Always save the custom color if we got here (since auto theme mode is disabled)
        customAccentColorHex = color.toHex() ?? ""
    }
    
    private func applyTheme(_ theme: String) {
        // Set the app's theme (will apply when app is restarted)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            switch theme {
            case "dark":
                window.overrideUserInterfaceStyle = .dark
            case "light":
                window.overrideUserInterfaceStyle = .light
            default:
                window.overrideUserInterfaceStyle = .unspecified
            }
        }
    }
}

struct ThemeOptionButton: View {
    let title: String
    let imageName: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 160)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? accentColor : Color.clear, lineWidth: 2)
                    )
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? accentColor : .primary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

