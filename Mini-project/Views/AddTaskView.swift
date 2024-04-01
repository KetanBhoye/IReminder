//
//  AddTaskView.swift
//  Mini-project
//
//  Created by mini project on 08/02/24.
//


import SwiftUI

struct CalculatorView: View {
    @State private var displayText = "0"
    
    let buttons: [[String]] = [
        ["7", "8", "9", "+"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "x"],
        ["C", "0", "=", "/"]
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            Text(displayText)
                .font(.largeTitle)
                .padding()
            
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { button in
                        Button(action: {
                            self.buttonPressed(button)
                        }) {
                            Text(button)
                                .font(.title)
                                .frame(width: buttonWidth(button), height: buttonHeight())
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(buttonWidth(button) / 2)
                        }
                    }
                }
            }
        }
    }
    
    func buttonPressed(_ button: String) {
        switch button {
        case "C":
            displayText = "0"
        case "=":
            displayText = evaluateExpression()
        default:
            if displayText == "0" {
                displayText = button
            } else {
                displayText += button
            }
        }
    }
    
    func evaluateExpression() -> String {
        let expression = NSExpression(format: displayText)
        if let result = expression.expressionValue(with: nil, context: nil) as? Double {
            return String(result)
        } else {
            return "Error"
        }
    }
    
    func buttonWidth(_ button: String) -> CGFloat {
        return button == "0" ? 160 : 80
    }
    
    func buttonHeight() -> CGFloat {
        return 80
    }
}

//struct ContentView: View {
//    var body: some View {
//        CalculatorView()
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
#Preview {
    CalculatorView()
}
