//
//  NewsPanelView.swift
//  MRI_iPad
//
//  Created by Boris Liu on 06.12.21.


import SwiftUI

struct NewsPanelView: View {
    static let gradientStart = Color(red: 239.0 / 255, green: 120.0 / 255, blue: 221.0 / 255)
    static let gradientEnd = Color(red: 239.0 / 255, green: 172.0 / 255, blue: 120.0 / 255)
    
   
   
    var body: some View {
        GeometryReader {
            proxy in
            VStack {
                NavigationView {
                    VStack {
                        
                    }
                    .navigationTitle("News Panel")
                    .toolbar {
                        ToolbarItemGroup(placement: ToolbarItemPlacement.navigationBarLeading) {
                            Button(action: {
                                
                            }, label: {
                                Text("Patient Summary ")}
                            )
                        }
                    }
                }
            
                HStack {
                    
                    VStack {
                        
                        //Training inside
                        ZStack {

                        RoundedRectangle(cornerRadius: 25)
                            .fill(LinearGradient(
                                  gradient: .init(colors: [Self.gradientStart, Self.gradientEnd]),
                                  startPoint: .init(x: 0, y: 0),
                                  endPoint: .init(x: 0, y: 0.6)
                                ))
                            .frame(width: proxy.size.width * 0.5, height: proxy.size.height * 0.36)
                                .padding()
                            Text("Training inside")
                                .foregroundColor(.white)
                                .font(.title)
                                .frame(width: proxy.size.width * 0.48, height: proxy.size.height * 0.34, alignment: .topLeading)
                            
                            Text("Boris is just crying all the time")
                                .foregroundColor(.white)
                                .frame(width: proxy.size.width * 0.46, height: proxy.size.height * 0.24, alignment: .topLeading)
                            Text(Date.now, format: .dateTime.hour().minute())
                                .foregroundColor(.white)
                                .font(.caption2)
                                .frame(width: proxy.size.width * 0.48, height: proxy.size.height * 0.23, alignment: .topTrailing)
                            Text("Training inside")
                                .foregroundColor(.white)
                                .font(.title)
                                .frame(width: proxy.size.width * 0.48, height: proxy.size.height * 0.34, alignment: .topLeading)
                            
                            Text("Boris don't know how to procceed")
                                .foregroundColor(.white)
                                .frame(width: proxy.size.width * 0.46, height: proxy.size.height * 0.17, alignment: .topLeading)
                            Text(Date.now, format: .dateTime.hour().minute())
                                .foregroundColor(.white)
                                .font(.caption2)
                                .frame(width: proxy.size.width * 0.48, height: proxy.size.height * 0.16, alignment: .topTrailing)
                            
                            
                        }
                        
                        //Comments
                        ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(LinearGradient(
                                  gradient: .init(colors: [Self.gradientStart, Self.gradientEnd]),
                                  startPoint: .init(x: 0.5, y: 0),
                                  endPoint: .init(x: 0.5, y: 0.6)
                                ))
                                .frame(width: proxy.size.width * 0.5, height: proxy.size.height * 0.36)
                                .padding()
                            Text("Comments")
                                .foregroundColor(.white)
                                .font(.title)
                                .frame(width: proxy.size.width * 0.48, height: proxy.size.height * 0.34, alignment: .topLeading)
                            HStack(spacing: 20) {
                                VStack {
                                    ZStack {
                                    RoundedRectangle(cornerRadius: 25)
                                    .frame(width: proxy.size.width * 0.11, height: proxy.size.height * 0.11)
                                    .foregroundColor(Color(red: 196.0 / 255, green: 196.0 / 255, blue: 196.0 / 255))
                                        Text("Holy Shit")
                                            .foregroundColor(.white)
                                    Image(systemName: "x.circle")
                                            .frame(width: proxy.size.width * 0.095, height: proxy.size.height * 0.095, alignment: .topTrailing)
                                            .foregroundColor(.red)
                                        
                                    }
                                    .padding()
                                
                                    ZStack {
                                    RoundedRectangle(cornerRadius: 25)
                                    .frame(width: proxy.size.width * 0.11, height: proxy.size.height * 0.11)
                                    .foregroundColor(Color(red: 196.0 / 255, green: 196.0 / 255, blue: 196.0 / 255))
                                        Image(systemName: "heart.fill").foregroundColor(.red)
                                    Image(systemName: "x.circle")
                                            .frame(width: proxy.size.width * 0.095, height: proxy.size.height * 0.095, alignment: .topTrailing)
                                            .foregroundColor(.red)
                                        
                                    }
                                    
                                        
                                }
                                VStack {
                                    ZStack {
                                    RoundedRectangle(cornerRadius: 25)
                                    .frame(width: proxy.size.width * 0.11, height: proxy.size.height * 0.11)
                                    .foregroundColor(Color(red: 196.0 / 255, green: 196.0 / 255, blue: 196.0 / 255))
                                        Text("4.3 > 5.0")
                                            .foregroundColor(.white)
                                    Image(systemName: "x.circle")
                                            .frame(width: proxy.size.width * 0.095, height: proxy.size.height * 0.095, alignment: .topTrailing)
                                            .foregroundColor(.red)
                                        
                                    }
                                    .padding()
                                    ZStack {
                                    RoundedRectangle(cornerRadius: 25)
                                    .frame(width: proxy.size.width * 0.11, height: proxy.size.height * 0.11)
                                    .foregroundColor(Color(red: 196.0 / 255, green: 196.0 / 255, blue: 196.0 / 255))
                                        Text("Click me!")
                                            .foregroundColor(.white)
                                    Image(systemName: "x.circle")
                                            .frame(width: proxy.size.width * 0.095, height: proxy.size.height * 0.095, alignment: .topTrailing)
                                            .foregroundColor(.red)
                                        
                                    }
                                    
                                }
                                VStack {
                                    ZStack {
                                    RoundedRectangle(cornerRadius: 25)
                                    .frame(width: proxy.size.width * 0.11, height: proxy.size.height * 0.11)
                                    .foregroundColor(Color(red: 196.0 / 255, green: 196.0 / 255, blue: 196.0 / 255))
                                        Text("Brügge memes")
                                            .foregroundColor(.white)
                                    Image(systemName: "x.circle")
                                            .frame(width: proxy.size.width * 0.095, height: proxy.size.height * 0.095, alignment: .topTrailing)
                                            .foregroundColor(.red)
                                        
                                    }
                                    .padding()
                                    ZStack {
                                    RoundedRectangle(cornerRadius: 25)
                                    .frame(width: proxy.size.width * 0.11, height: proxy.size.height * 0.11)
                                    .foregroundColor(Color(red: 196.0 / 255, green: 196.0 / 255, blue: 196.0 / 255))
                                        Text("Oh God")
                                            .foregroundColor(.white)
                                    Image(systemName: "x.circle")
                                            .frame(width: proxy.size.width * 0.095, height: proxy.size.height * 0.095, alignment: .topTrailing)
                                            .foregroundColor(.red)
                                        
                                    }
                                        
                                }
                            }
                            
                            
                        }
                        
                    }
                    VStack {
                        
                        //Messages
                        ZStack {
                            
                         //TODO Add remove/unread
                            RoundedRectangle(cornerRadius: 25)
                            .fill(LinearGradient(
                                  gradient: .init(colors: [Self.gradientStart, Self.gradientEnd]),
                                  startPoint: .init(x: 0, y: 0),
                                  endPoint: .init(x: 0, y: 0.6)
                                ))
                            .frame(width: proxy.size.width * 0.33, height: proxy.size.height * 0.77)
                                .padding()
                            Text("Messages")
                                .foregroundColor(.white)
                                .font(.title)
                                .frame(width: proxy.size.width * 0.31, height: proxy.size.height * 0.75, alignment: .topLeading)
                            VStack {
                                RoundedRectangle(cornerRadius: 25)
                                .frame(width: proxy.size.width * 0.33, height: proxy.size.height * 0.75)
                                .foregroundColor(.clear)
                                }
                            HStack {
                                Image(systemName: "person.crop.circle").resizable().frame(width: 44, height: 44, alignment: .topLeading).clipShape(Circle())
                                VStack(alignment: .leading) {
                                    Text("Max Kapsecker")
                                    Text("Test").font(.caption).foregroundColor(.white)
                                }
                                .frame(alignment: .topLeading)
                                
                                
                            }
                        
                            
                        }
                    }
                }
                
            }
        }
    }
  /*  func showAlert() {
        let alert = UIAlertController(title: "Alert", message: "Wait Please!", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
    }
   */
   // func delete(at offsets: IndexSet) {
    //    messages.items.remove(atOffsets: offsets)
   // }
}

struct NewsPanelView_Previews: PreviewProvider {
    static var previews: some View {
        NewsPanelView()
.previewInterfaceOrientation(.landscapeLeft)
    }
}
