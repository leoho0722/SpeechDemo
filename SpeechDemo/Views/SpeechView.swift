//
//  SpeechView.swift
//  SpeechDemo
//
//  Created by Leo Ho on 2024/3/15.
//

import SwiftHelpers
import SwiftUI

struct SpeechView: View {
    var body: some View {
        VStack {
            Button {
                // 點下去，要做語音轉文字
            } label: {
                Image(symbols: .micCircle)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 100)
            }
        }
        .padding()
    }
}

#Preview {
    SpeechView()
}
