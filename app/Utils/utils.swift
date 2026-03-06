//
//  utils.swift
//  app
//
//  Created by Foundation 34 on 05/03/26.
//

import SwiftUI

public struct BackgroundedText: View {

    var color : Color = .cyan
    var text_color : Color = .white
    var size = CGSize(width: 200, height: 100)
  
    var text : String = "Hello world!"

    init(_ txt: String, _ color : Color, _ text_color : Color, _ size: CGSize) {
        self.text = txt
        self.text_color = text_color
        self.color = color
        self.size = size
    }


    public var body: some View {
        ZStack{
            Rectangle()
                .frame(width: self.size.width,
                       height: self.size.height)
                .foregroundColor(self.color)

            Text(self.text)
                .foregroundColor(self.text_color)

        }
    }
}

