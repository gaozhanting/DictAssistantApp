//
//  WordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/22.
//

import SwiftUI

struct WordsView: View {
    var body: some View {
        Text("some words")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.green)
    }
}

struct WordsView_Previews: PreviewProvider {
    static var previews: some View {
        WordsView()
    }
}

