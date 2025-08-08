//
//  CustomTextField.swift
//  logdog-demo
//
//  Created by kelvinfok on 4/8/25.
//

import SwiftUI

struct CustomTextField: View {
  var title: String
  @Binding var text: String
  
  var body: some View {
    TextField(title, text: $text)
      .padding()
      .background(Color(.systemGray6))
      .cornerRadius(10)
      .autocapitalization(.none)
      .textInputAutocapitalization(.never)
  }
}

struct CustomSecureField: View {
  var title: String
  @Binding var text: String
  
  var body: some View {
    SecureField(title, text: $text)
      .padding()
      .background(Color(.systemGray6))
      .cornerRadius(10)
  }
}
