//
//  MarkListRow.swift
//  ToTime
//
//  Created by 김민국 on 2020/03/07.
//  Copyright © 2020 김민국. All rights reserved.
//

import SwiftUI

struct MarkListRow: View {
    var mark: MarkData
    
    var body: some View {
        VStack{
            HStack{
                Image(uiImage: loadIcon(fileName: mark.iconName) ?? UIImage(systemName: "house")!)
                .resizable()
                    .frame(width: UIScreen.main.bounds.width/10, height: UIScreen.main.bounds.width/10)
                Text("\(mark.name)")
                    .padding(.leading, 15)
            }
        }
    }
}

struct MarkListRow_Previews: PreviewProvider {
    static var previews: some View {
        MarkListRow(mark: MarkData(name: "", longitude: 0.0, latitude: 0.0, address: "",iconName: ""))
    }
}
