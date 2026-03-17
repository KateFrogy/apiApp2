//
//  SmView.swift
//  api
//
//  Created by Екатерина Исаева on 17.03.2026.
//

import SwiftUI

// MARK: - модели данных

struct dogFact: Identifiable, Decodable {
    let id = UUID() // что это и зачем вообще нужно
    let data: [String]
    
    var fact: String {
            data.first ?? "No fact"
        }
}

// MARK: - сам экран
struct SmView: View {
    
    @State private var result: dogFact?
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            Text ("Random dogs fact")
            Button("Show fact") {
                searchFact()
            }
            if let result = result {
                VStack{
                    Text(result.fact)
                }
            }
        }
    }
    
    func searchFact() {
        result = nil
        errorMessage = ""
        
        //создание url
        let urlString = "https://meowfacts.herokuapp.com/"
        guard let url = URL(string: urlString) else {
            errorMessage = "no facts"
            return
        }
        // do request
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "ошибка"
                    return
                }
                guard let data = data else {
                    errorMessage = "ошибка из гуард лет"
                    return
                }
                
                do {
                    // парсим json
                    // let facts = try JSONDecoder().decode([dogFact].self, from: data) // ❌ ОШИБКА

                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("json \(jsonString)")
                    }
                    let factResponse = try JSONDecoder().decode(dogFact.self, from: data)
                    result = factResponse
                } catch {
                    errorMessage = "error from do catch"
                    print("Ошибка декодирования: \(error)")
                }
            }
        }.resume()
    }
}
