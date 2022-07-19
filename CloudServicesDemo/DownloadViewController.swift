//
//  DownloadViewController.swift
//  TestingNewIDEVersion
//
//  Created by Vitor Gledison Oliveira de Souza on 19/10/21.
//

import UIKit

class DownloadViewController: UIViewController {

    private lazy var dataButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.title = "Download"
        button.configuration?.baseForegroundColor = .white
        button.configuration?.baseBackgroundColor = .darkGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        view.addSubview(dataButton)
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            dataButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dataButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dataButton.heightAnchor.constraint(equalToConstant: 70.0),
            dataButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2606),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        dataButton.addTarget(self, action: #selector(downloadButtonAction), for: .touchUpInside)
    }

    // MARK: - Download Button Action
    
    @objc private func downloadButtonAction() {
        Task {
            await downloadTask()
        }
    }
    
    // MARK: - Download Task
    
    private func downloadTask() async {
        
        /// Verificando se é possível verificar criar uma URL
        if let url = URL(string: "https://i.pinimg.com/originals/a9/32/9b/a9329b6beb4d240a05cef743877b59eb.jpg") {
            
            /// Bloco que tenta executar um trecho de código que pode lançar um erro
            do {
                
                /// Tenta fazer o download de um arquivo, se der tudo certo irá retornar um
                /// (URL, URLResponse), se der errado um erro é lançado
                /// await --> espera um recurso ser processado assincronamente (paralelamente)
                let (fileUrl, _) = try await URLSession.shared.download(from: url)
                
                /// Cria um objeto do tipo Data apartir da URL do arquivo temporário baixado
                let imageData = try Data(contentsOf: fileUrl)
                
                /// Altera a UI dentro da main thread evitando problemas de congelamento da interface
                DispatchQueue.main.async {
                    self.imageView.image = .init(data: imageData)
                }
            } catch {
                print("Download task error")
            }
        }
    }
}
