//
//  MainTabView.swift
//  StikJIT
//
//  Created by Stephen on 3/27/25.
//

import SwiftUI
import SwiftGlass

// Modern glass-style tab bar with more squared shape
struct GlassTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(icon: String, title: String)]
    let accentColor: Color
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[index].icon)
                            .font(.system(size: 20))
                            .foregroundStyle(selectedTab == index ? 
                                LinearGradient(
                                    colors: [accentColor, accentColor.opacity(0.85)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) : 
                                LinearGradient(
                                    colors: [.gray.opacity(0.75), .gray.opacity(0.6)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        Text(tabs[index].title)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(selectedTab == index ? accentColor : .gray.opacity(0.75))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        Group {
                            if selectedTab == index {
                                if colorScheme == .dark {
                                    // Dark mode selected tab effect - more squared
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(accentColor.opacity(0.18))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .strokeBorder(
                                                    LinearGradient(
                                                        colors: [
                                                            accentColor.opacity(0.3),
                                                            accentColor.opacity(0.05)
                                                        ],
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                        .shadow(color: accentColor.opacity(0.3), radius: 4, x: 0, y: 0)
                                        .matchedGeometryEffect(id: "TAB_EFFECT", in: namespace)
                                } else {
                                    // Light mode selected tab with 3D minimalist effect - more squared
                                    ZStack {
                                        // Soft shadow underneath to create depth
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.black.opacity(0.03))
                                            .blur(radius: 2)
                                            .offset(y: 1)
                                        
                                        // Main rounded rectangle with subtle gradient fill
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.85),
                                                        accentColor.opacity(0.08)
                                                    ],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .strokeBorder(
                                                        LinearGradient(
                                                            colors: [
                                                                accentColor.opacity(0.25),
                                                                accentColor.opacity(0.05)
                                                            ],
                                                            startPoint: .top,
                                                            endPoint: .bottom
                                                        ),
                                                        lineWidth: 0.7
                                                    )
                                            )
                                            .shadow(color: accentColor.opacity(0.15), radius: 2, x: 0, y: 1)
                                        
                                        // Subtle top highlight for 3D effect
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .strokeBorder(
                                                        LinearGradient(
                                                            colors: [
                                                                Color.white.opacity(0.6),
                                                                Color.white.opacity(0)
                                                            ],
                                                            startPoint: .top,
                                                            endPoint: .center
                                                        ),
                                                        lineWidth: 1.2
                                                    )
                                                    .padding(0.5)
                                            )
                                    }
                                    .matchedGeometryEffect(id: "TAB_EFFECT", in: namespace)
                                }
                            }
                        }
                    )
                    .scaleEffect(selectedTab == index ? 1 : 0.97)
                    .animation(.spring(response: 0.2, dampingFraction: 0.7), value: selectedTab)
                }
            }
        }
        .padding(5)
        .glass(
            radius: 20, // More squared overall tab bar
            material: colorScheme == .dark ? .regularMaterial : .thinMaterial,
            gradientOpacity: colorScheme == .dark ? 0.12 : 0.05,
            shadowColor: colorScheme == .dark ? .clear : accentColor,
            shadowOpacity: colorScheme == .dark ? 0 : 0.1,
            shadowRadius: colorScheme == .dark ? 0 : 5
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20) // More squared overall tab bar
                .strokeBorder(
                    LinearGradient(
                        colors: colorScheme == .dark ? 
                            [.white.opacity(0.15), .white.opacity(0.05)] :
                            [accentColor.opacity(0.15), accentColor.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
        .shadow(color: .clear, radius: 0, x: 0, y: 0)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .frame(height: 62)
        .onChange(of: selectedTab) { _ in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        .modifier(LightModeShadowModifier(accentColor: accentColor))
    }
    
    @Namespace private var namespace
}

// Custom modifier to apply shadow only in light mode
struct LightModeShadowModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let accentColor: Color
    
    func body(content: Content) -> some View {
        if colorScheme == .light {
            content
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
        } else {
            content
        }
    }
}

struct MainTabView: View {
    @AppStorage("customAccentColor") private var customAccentColorHex: String = ""
    @AppStorage("useGlassTabBar") private var useGlassTabBar = false
    @State private var selectedTab = 0
    @Environment(\.colorScheme) private var colorScheme
    
    private var accentColor: Color {
        if customAccentColorHex.isEmpty {
            return .blue
        } else {
            return Color(hex: customAccentColorHex) ?? .blue
        }
    }
    
    private let tabs = [
        (icon: "house.fill", title: "Home"),
        (icon: "gearshape.fill", title: "Settings")
    ]
    
    var body: some View {
        // Use the standard SwiftUI TabView if glass effect is disabled
        if !useGlassTabBar {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }
            .accentColor(accentColor)
            .environment(\.accentColor, accentColor)
        } else {
            // Use custom glass tab bar
            ZStack {
                // Background color that matches the system background
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                    
                // Content views with transparent background - no bottom padding
                ZStack {
                    if selectedTab == 0 {
                        HomeView()
                            .transition(.opacity)
                    } else {
                        SettingsView()
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.15), value: selectedTab)
                
                // Custom tab bar overlay at the bottom, now floating
                VStack {
                    Spacer()
                    GlassTabBar(selectedTab: $selectedTab, tabs: tabs, accentColor: accentColor)
                        .padding(.bottom, 15)
                        .padding(.horizontal, 18)
                }
            }
            .ignoresSafeArea(.keyboard)
            .accentColor(accentColor)
            .environment(\.accentColor, accentColor)
        }
    }
}

// Standard non-glass tab bar implementation
struct StandardTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(icon: String, title: String)]
    let accentColor: Color
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[index].icon)
                            .font(.system(size: 20))
                            .foregroundColor(selectedTab == index ? accentColor : .gray)
                        
                        Text(tabs[index].title)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(selectedTab == index ? accentColor : .gray)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
        .onChange(of: selectedTab) { _ in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}