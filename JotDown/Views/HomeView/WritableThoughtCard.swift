//
//  WritableThoughtCard.swift
//  JotDown
//
//  Created by Drew Mendelow on 10/14/25.
//
import SwiftUI

struct WritableThoughtCard: View {
    @Binding var text: String
    @FocusState var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
           RoundedRectangle(cornerRadius: 30)
               .fill(Color.white.opacity(0.61))
               .frame(width: 337, height: 436)
               .shadow(color: Color.black.opacity(0.05), radius: 7.7, x: 0, y: 2)
//               .glassEffect()
           
           VStack(alignment: .leading) {
               ZStack(alignment: .topLeading) {
                   if text.isEmpty {
                       // Placeholder text for the TextEditor since it doesn't have a placeholder property
                       Text("Start writing...")
                           .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
                           .font(.system(size: 24, weight: .regular))
                   }
                   
                   ClearTextEditor(text: $text)
                       .focused($isFocused)
               }
           }
           .padding(EdgeInsets(top: 28, leading: 33, bottom: 28, trailing: 33))
           .frame(width: 337, height: 436)
       }
       .frame(width: 337, height: 472)
    }
}

// Custom Text Editor to get a clear background
struct ClearTextEditor: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.delegate = context.coordinator
        
        let font = UIFont.systemFont(ofSize: 24, weight: .regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        
        textView.font = font
        textView.typingAttributes = [
            .font: font,
            .foregroundColor: UIColor(red: 0.49, green: 0.58, blue: 0.70, alpha: 1),
            .paragraphStyle: paragraphStyle
        ]
        
        textView.text = text
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .prominent, target: textView, action: #selector(textView.resignFirstResponder))
        toolbar.items = [flexSpace, doneButton]
        textView.inputAccessoryView = toolbar
        
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        
        // Ensure typingAttributes are correct while typing
        let font = UIFont.systemFont(ofSize: 24, weight: .regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = font.pointSize * 0.5
        
        uiView.typingAttributes = [
            .font: font,
            .foregroundColor: UIColor(red: 0.49, green: 0.58, blue: 0.70, alpha: 1),
            .paragraphStyle: paragraphStyle
        ]
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: ClearTextEditor

        init(_ parent: ClearTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}
