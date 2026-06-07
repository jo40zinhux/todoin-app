//
//  TodoinExtensionsBundle.swift
//  TodoinExtensions
//
//  Target unificado: Home Widget (WidgetKit) + Live Activity (ActivityKit).
//

import WidgetKit
import SwiftUI

@main
struct TodoinExtensionsBundle: WidgetBundle {
    var body: some Widget {
        TodoinHomeWidget()
        if #available(iOS 16.1, *) {
            TodoinTimerLiveActivity()
        }
    }
}
