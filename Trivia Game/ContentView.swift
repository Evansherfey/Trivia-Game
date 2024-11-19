//
//  ContentView.swift
//  Trivia Game
//
//  Created by Student on 11/18/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var triviaManager = TriviaManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                VStack(spacing: 20) {
                    Text("Questions and Answers")
                        .lilacTitle()
                    
                    Text("Are you ready for the challenge?")
                        .foregroundColor(Color("AccentColor"))
                }
                struct PrimaryButton: View {
                    var text: String
                    var background: Color = Color("AccentColor")
                    
                    var body: some View {
                        Text(text)
                            .foregroundColor(.white)
                            .padding()
                            .padding(.horizontal)
                            .background(background)
                            .cornerRadius(30)
                            .shadow(radius: 10)
                    }
                }

                struct PrimaryButton_Previews: PreviewProvider {
                    static var previews: some View {
                        PrimaryButton(text: "Next")
                    }
                }
                
                NavigationLink {
                    TriviaView()
                        .environmentObject(triviaManager)
                } label: {
                    PrimaryButton(text: "Let's go!")
                }
            }
            
            struct AnswerRow: View {
                @EnvironmentObject var triviaManager: TriviaManager
                var answer: Answer
                @State private var isSelected = false

                var green = Color(hue: 5, saturation: 8, brightness: 0.55)
                var red = Color(red: 3, green: 10, blue: 5)
                
                var body: some View {
                    HStack(spacing: 20) {
                        Image(systemName: "circle.fill")
                            .font(.caption)
                        
                        Text(answer.text)
                            .bold()
                        
                        if isSelected {
                            Spacer()
                            
                            Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "x.circle.fill")
                                .foregroundColor(answer.isCorrect ? green : red)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(triviaManager.answerSelected ? (isSelected ? Color("AccentColor") : .gray) : Color("AccentColor"))
                    .background(.white)
                    .cornerRadius(10)
                    .shadow(color: isSelected ? answer.isCorrect ? green : red : .gray, radius: 5, x: 0.5, y: 0.5)
                    .onTapGesture {
                        if !triviaManager.answerSelected {
                            isSelected = true
                            triviaManager.selectAnswer(answer: answer)

                        }
                    }
                }
            }

            struct AnswerRow_Previews: PreviewProvider {
                static var previews: some View {
                    AnswerRow(answer: Answer(text: "Single", isCorrect:  false))
                        .environmentObject(TriviaManager())
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
            .background(Color(red: 22, green: 33, blue: 27))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct QuestionView: View {
    @EnvironmentObject var triviaManager: TriviaManager

    var body: some View {
        VStack(spacing: 40) {
            HStack {
                Text("Trivia Game")
                    .lilacTitle()
                
                Spacer()
                
                Text("\(triviaManager.index + 1) out of \(triviaManager.length)")
                    .foregroundColor(Color("AccentColor"))
                    .fontWeight(.heavy)
            }
            
            ProgressBar(progress: triviaManager.progress)
            
            VStack(alignment: .leading, spacing: 20) {
                Text(triviaManager.question)
                    .font(.system(size: 20))
                    .bold()
                    .foregroundColor(.gray)
                
                ForEach(triviaManager.answerChoices, id: \.id) { answer in
                    AnswerRow(answer: answer)
                        .environmentObject(triviaManager)
                }
            }
            
            Button {
                triviaManager.goToNextQuestion()
            } label: {
                PrimaryButton(text: "Next", background: triviaManager.answerSelected ? Color("AccentColor") : Color(hue: 1.0, saturation: 0.0, brightness: 9.0, opacity: 0.327))
            }
            .disabled(!triviaManager.answerSelected)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(red: 0.984313725490196, green: 0.9294117647058824, blue: 0.8470588235294118))
        .navigationBarHidden(true)
    }
}

struct QuestionView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionView()
            .environmentObject(TriviaManager())
    }
}

struct TriviaView: View {
    @EnvironmentObject var triviaManager: TriviaManager

    var body: some View {
        if triviaManager.reachedEnd {
            VStack(spacing: 20) {
                Text("Trivia Game")
                    .lilacTitle()

                Text("Good work, you completed the game!")
                
                Text("You scored \(triviaManager.score) out of \(triviaManager.length)")
                
                Button {
                    Task.init {
                        await triviaManager.fetchTrivia()
                    }
                } label: {
                    PrimaryButton(text: "Play again")
                }
            }
            .foregroundColor(Color("AccentColor"))
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 1.7, green: 1.3, blue: 5.4))
        } else {
            QuestionView()
                .environmentObject(triviaManager)
        }
    }
}

struct TriviaView_Previews: PreviewProvider {
    static var previews: some View {
        TriviaView()
            .environmentObject(TriviaManager())
    }
}
