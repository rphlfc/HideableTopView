//
//  HideableSearchBar.swift
//  HideableSearchBar
//
//  Created by Raphael Cerqueira on 22/08/21.
//

import SwiftUI

struct HideableTopView<TopContent: View, Content: View>: View {
    @Environment(\.presentationMode) var presentation
    @State var topViewHeight: CGFloat = 0
    @State var topViewOffset: CGFloat = 0
    @State var topViewCurrentOffset: CGFloat = 0
    
    @State var bottomViewOffset: CGFloat = 0
    @State var bottomViewHeight: CGFloat = 0
    @State var bottomViewCurrentOffset: CGFloat = 0
    
    var safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets
    
    var topViewContent: TopContent
    var content: Content
    
    init(@ViewBuilder topViewContent: () -> TopContent, @ViewBuilder content: () -> Content) {
        self.topViewContent = topViewContent()
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            topViewContent
                .foregroundColor(.primary)
                .zIndex(1)
                .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.top))
                .offset(y: topViewOffset)
                .overlay(
                    GeometryReader { reader -> Color in
                        let height = reader.frame(in: .global).height
                        if topViewHeight == 0 {
                            DispatchQueue.main.async {
                                topViewHeight = height
                            }
                        }
                        return Color.clear
                    }
                    , alignment: .top
                )
            
            GeometryReader { reader in
                content
                    .zIndex(0)
                    .padding(.vertical)
                    .padding(.top, topViewHeight)
                    .offset(y: bottomViewOffset)
                    .overlay(
                        GeometryReader { reader -> Color in
                            let height = reader.frame(in: .global).height
                            if bottomViewHeight == 0 {
                                DispatchQueue.main.async {
                                    bottomViewHeight = height
                                }
                            }
                            return Color.clear
                        }
                        , alignment: .top
                    )
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                let auxOffset = bottomViewCurrentOffset + value.translation.height
                                let screenHeight = UIScreen.main.bounds.height
                                let maxOffset = screenHeight - bottomViewHeight - (safeAreaInsets?.top ?? 15) - (safeAreaInsets?.bottom ?? 15) - topViewHeight
                                
                                if value.translation.height < 0 && auxOffset < maxOffset { // up
                                    bottomViewOffset = maxOffset
                                } else if auxOffset > 0 {
                                    bottomViewOffset = 0
                                } else {
                                    bottomViewOffset = auxOffset
                                }
                                
                                // top view
                                let auxTopViewOffset = topViewCurrentOffset + value.translation.height
                                if auxTopViewOffset > 0 {
                                    topViewOffset = 0
                                } else {
                                    if auxTopViewOffset < -topViewHeight - (safeAreaInsets?.top ?? 20) {
                                        topViewOffset = -topViewHeight - (safeAreaInsets?.top ?? 20)
                                    } else {
                                        topViewOffset = auxTopViewOffset
                                    }
                                }
                            })
                            .onEnded({ value in
                                bottomViewCurrentOffset = bottomViewOffset
                                
                                // top view
                                if bottomViewOffset < -(topViewHeight + (safeAreaInsets?.top ?? 20)) {
                                    if topViewOffset > -(topViewHeight / 2) {
                                        withAnimation {
                                            topViewOffset = 0
                                        }
                                    } else {
                                        withAnimation {
                                            topViewOffset = -topViewHeight - (safeAreaInsets?.top ?? 20)
                                        }
                                    }
                                }
                                
                                topViewCurrentOffset = topViewOffset
                            })
                    )
            }
        }
        .navigationBarHidden(true)
    }
}

struct HideableTopView_Previews: PreviewProvider {
    static var previews: some View {
        HideableTopView {
            VStack(spacing: 0) {
                HStack(spacing: 15) {
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "arrow.left")
                    })
                    
                    Spacer()
                    
                    Button(action: {}, label: {
                        Image(systemName: "magnifyingglass")
                    })
                    
                    Button(action: {}, label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                    })
                }
                .font(.system(size: 21))
                .padding()
                
                Divider()
            }
        } content: {
            VStack {
                ForEach(0 ..< 15) { item in
                    VStack(alignment: .leading) {
                        Text("Content \(item)")
                            .padding()
                        
                        Divider()
                    }
                }
            }
        }
    }
}

