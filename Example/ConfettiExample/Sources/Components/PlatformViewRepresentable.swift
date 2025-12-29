//
//  PlatformViewRepresentable.swift
//  ConfettiExample
//
//  Created by Takehito Koshimizu on 2025/12/29.
//

import SwiftUI

#if canImport(UIKit) && !os(macOS)
typealias PlatformView = UIView
typealias PlatformViewController = UIViewController
typealias PlatformViewRepresentable = UIViewRepresentable
typealias PlatformViewControllerRepresentable = UIViewControllerRepresentable
#elseif os(macOS) && !targetEnvironment(macCatalyst)
typealias PlatformView = NSView
typealias PlatformViewController = NSViewController
typealias PlatformViewRepresentable = NSViewRepresentable
typealias PlatformViewControllerRepresentable = NSViewControllerRepresentable
#endif

// MARK: - PlatformAgnosticViewRepresentable

protocol PlatformAgnosticViewRepresentable: PlatformViewRepresentable {
    associatedtype PlatformViewType
    func makePlatformView(context: Context) -> PlatformViewType
    func updatePlatformView(_ platformView: PlatformViewType, context: Context)
}

#if canImport(UIKit) && !os(macOS)
extension PlatformAgnosticViewRepresentable where UIViewType == PlatformViewType {
    func makeUIView(context: Context) -> UIViewType {
        makePlatformView(context: context)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        updatePlatformView(uiView, context: context)
    }
}

#elseif os(macOS) && !targetEnvironment(macCatalyst)
extension PlatformAgnosticViewRepresentable where NSViewType == PlatformViewType {
    func makeNSView(context: Context) -> NSViewType {
        makePlatformView(context: context)
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
        updatePlatformView(nsView, context: context)
    }
}
#endif

// MARK: - PlatformAgnosticViewControllerRepresentable

protocol PlatformAgnosticViewControllerRepresentable: PlatformViewControllerRepresentable {
    associatedtype PlatformViewControllerType
    func makePlatformViewController(context: Context) -> PlatformViewControllerType
    func updatePlatformViewController(_ platformView: PlatformViewControllerType, context: Context)
}

#if canImport(UIKit) && !os(macOS)
extension PlatformAgnosticViewControllerRepresentable where UIViewControllerType == PlatformViewControllerType {
    func makeUIViewController(context: Context) -> UIViewControllerType {
        makePlatformViewController(context: context)
    }

    func updateUIViewController(_ viewController: UIViewControllerType, context: Context) {
        updatePlatformViewController(viewController, context: context)
    }
}

#elseif os(macOS) && !targetEnvironment(macCatalyst)
extension PlatformAgnosticViewControllerRepresentable where NSViewControllerType == PlatformViewControllerType {
    func makeNSViewController(context: Context) -> NSViewControllerType {
        makePlatformViewController(context: context)
    }

    func updateNSViewController(_ viewController: NSViewControllerType, context: Context) {
        updatePlatformViewController(viewController, context: context)
    }
}
#endif
