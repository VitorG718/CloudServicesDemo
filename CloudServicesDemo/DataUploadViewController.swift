//
//  ViewController.swift
//  TestingNewIDEVersion
//
//  Created by Vitor Gledison Oliveira de Souza on 21/09/21.
//

import UIKit

class DataUploadViewController: UIViewController {
    
    /// O modelo de carro que será utilizado para decodificar e decodificar um json
    struct CarModel: Codable {
        var Marca: String
        var Valor: String
        var Modelo: String
        var Combustivel: String
        var SiglaCombustivel: String
        var MesReferencia: String
        var AnoModelo: Int
        var TipoVeiculo: Int
    }
    
    /// O modelo de user que será utilizado para decodificar e decodificar um json
    struct User: Codable {
        var name: String
        var age: Int
    }
    
    private lazy var dataButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.title = "Fetch Data"
        button.configuration?.baseForegroundColor = .white
        button.configuration?.baseBackgroundColor = .purple
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var uploadButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.title = "Upload Data"
        button.configuration?.baseForegroundColor = .white
        button.configuration?.baseBackgroundColor = .blue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.font = label.font.withSize(20.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        view.addSubview(label)
        view.addSubview(uploadButton)
        view.addSubview(dataButton)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            label.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            dataButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dataButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dataButton.heightAnchor.constraint(equalToConstant: 70.0),
            dataButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            uploadButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            uploadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            uploadButton.heightAnchor.constraint(equalToConstant: 70.0),
            uploadButton.bottomAnchor.constraint(equalTo: dataButton.topAnchor, constant: -10.0)

        ])
        
        dataButton.addTarget(self, action: #selector(dataButtonAction), for: .touchUpInside)
        uploadButton.addTarget(self, action: #selector(uploadButtonAction), for: .touchUpInside)
    }
    
    @objc private func dataButtonAction() {
        dataTask()
    }
    
    @objc private func uploadButtonAction() {
        uploadTask()
    }
    
    // MARK: - Data Task
    private func dataTask() {
        
        /// Verificando se é possível verificar criar uma URL
        if let url = URL(string: "https://parallelum.com.br/fipe/api/v1/carros/marcas/7/modelos/7088/anos/2016-1") {
            
            /// Pega uma referencia para a session compartilhada
            let session = URLSession.shared
            
            /// Cria uma task para download de dados que serão armazenados em memória
            let dataTask = session.dataTask(with: url) { data, response, error in
                
                /// Verifica se houve algum error com a requisição
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    
                    /// Verifica as informações do response, como status code e tipo de dado recebido
                    guard let response = response as? HTTPURLResponse,
                            response.statusCode == 200 &&
                            response.mimeType == "application/json"
                    else {
                        print("Wrong headers")
                        return
                    }
                    
                    /// Cria um objeto para decodificar as informações
                    let decoder = JSONDecoder()
                    
                    /// Verifica a existência do dado e tenta uma conversão para um tipo mapeado no projeto
                    if let data = data, let carData = try? decoder.decode(CarModel.self, from: data) {
                        
                        /// Faz o carregamento das informações na UI na thread principal
                        DispatchQueue.main.async {
                            self.label.text = "Marca: \(carData.Marca)\nModelo: \(carData.Modelo)\nValor: \(carData.Valor)"
                        }
                    } else {
                        print("Error on decoding process")
                    }
                }
            }
            
            /// Executa a tarefa
            dataTask.resume()
        }
    }
    
    // MARK: - Upload Task
    
    private func uploadTask() {
        
        /// Bloco que tenta executar um trecho de código que pode lançar um erro
        if let url = URL(string: "http://localhost:3000") {
            
            /// Pega uma referencia para a session compartilhada
            let session = URLSession.shared
            
            /// Cria objeto para o encoder e decoder
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()
            
            /// Cria uma request com o método POST e informa que o tipo de dados enviado
            /// Será um JSON
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            /// Cria um novo usuário e converte o objeto para um dado JSON
            let user = User(name: "Vitor", age: 21)
            let userData = try! encoder.encode(user)
            
            /// Cria uma tarefa de envio de informações
            let uploadTask = session.uploadTask(with: request, from: userData) { data, response, error in
                
                /// Checa a existência de erros
                guard error == nil else {
                    print("Error: \(error!.localizedDescription)")
                    return
                }
                
                /// Verifica a resposta do servidor
                guard let response = response as? HTTPURLResponse,
                        response.statusCode == 201 &&
                        response.mimeType == "application/json"
                else {
                    print("Wrong headers")
                    return
                }
                
                /// Faz a decodificação dos dados
                if let data = data, let jsonData = try? decoder.decode(User.self, from: data) {
                    
                    /// Atualiza a UI
                    DispatchQueue.main.async {
                        self.label.text = "Name: \(jsonData.name)\nAge: \(jsonData.age)"
                    }
                } else {
                    print("Parsing data error")
                }
                
            }
            
            /// Executa a tarefa
            uploadTask.resume()
        }
    }
}

