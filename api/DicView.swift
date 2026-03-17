//
//  DicView.swift
//  api
//
//  Created by Екатерина Исаева on 17.03.2026.
//

//
//  ContentView.swift
//  SimpleDictionary
//
//  Просто скопируй это в ContentView.swift нового SwiftUI проекта
//

import SwiftUI

// MARK: - Простые модели данных
struct WordData: Codable, Identifiable {
    let id = UUID()
    let word: String
    let meanings: [MeaningData]
    
    enum CodingKeys: String, CodingKey {
        case word, meanings
    }
}

struct MeaningData: Codable, Identifiable {
    let id = UUID()
    let partOfSpeech: String
    let definitions: [DefinitionData]
}

struct DefinitionData: Codable, Identifiable {
    let id = UUID()
    let definition: String
    let example: String?
}

// MARK: - Главный экран
struct DicView: View {
    @State private var word = ""              // Слово для поиска
    @State private var result: WordData?      // Результат поиска
    @State private var isLoading = false       // Показывать загрузку?
    @State private var errorMessage = ""       // Сообщение об ошибке
    
    var body: some View {
        VStack(spacing: 20) {
            // Заголовок
            Text("Простой словарь")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Поле ввода
            HStack {
                TextField("Введите слово", text: $word)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                Button("Найти") {
                    searchWord()
                }
                .buttonStyle(.borderedProminent)
                .disabled(word.isEmpty || isLoading)
            }
            .padding(.horizontal)
            
            // Индикатор загрузки
            if isLoading {
                ProgressView("Ищем слово...")
            }
            
            // Сообщение об ошибке
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            // Результаты поиска
            if let result = result {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Слово: \(result.word)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(result.meanings) { meaning in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(meaning.partOfSpeech)
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                
                                ForEach(meaning.definitions) { def in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("• " + def.definition)
                                        
                                        if let example = def.example {
                                            Text("Пример: \"\(example)\"")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .padding(.leading, 15)
                                        }
                                    }
                                    .padding(.leading, 5)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    // Функция поиска слова
    func searchWord() {
        // Сбрасываем старые результаты
        result = nil
        errorMessage = ""
        isLoading = true
        
        // Создаем URL
        let urlString = "https://api.dictionaryapi.dev/api/v2/entries/en/\(word)"
        guard let url = URL(string: urlString) else {
            errorMessage = "Неверный URL"
            isLoading = false
            return
        }
        
        // Делаем запрос
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = "Ошибка: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    errorMessage = "Нет данных"
                    return
                }
                
                do {
                    // Парсим JSON
                    let words = try JSONDecoder().decode([WordData].self, from: data)
                    result = words.first
                } catch {
                    errorMessage = "Слово не найдено"
                }
            }
        }.resume()
        
    }
}

// MARK: - Превью

