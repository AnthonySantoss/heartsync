# Mapa Arquitetural - HeartSync

Guia de referência para desenvolvedores da estrutura do projeto HeartSync, seguindo **MVVM + Clean Architecture**.

---

## 📁 Estrutura de Pastas

```plaintext
heartsync/
├── lib/
│   ├── src/
│   │   ├── core/          # Recursos globais
│   │   ├── features/      # Funcionalidades modulares
│   │   └── app/           # Configurações do app
│   ├── main.dart          # Entry point
├── assets/                # Recursos estáticos
├── test/                  # Testes
└── pubspec.yaml           # Dependências
🏗️ Camadas Principais
1. core/
Recursos compartilhados entre features

Subpasta	Finalidade	Exemplos
constants/	Valores imutáveis	app_colors.dart, routes.dart
utils/	Auxiliares genéricos	validators.dart, date_formatter.dart
services/	Lógica externa compartilhada	api_service.dart, auth_service.dart
shared/	Widgets/estilos reutilizáveis	gradient_background.dart, custom_text.dart
2. features/
Cada feature é um módulo independente (ex: auth, home)

Estrutura por Feature:
plaintext
Copy
feature/
├── data/
│   ├── models/          # Modelos de dados (DTOs)
│   └── repositories/    # Implementação de repositórios
├── domain/
│   ├── entities/        # Entidades de negócio
│   ├── use_cases/       # Lógica de negócio
│   └── repositories/    # Interfaces abstratas
└── presentation/
    ├── view/            # Telas (Pages/Screens)
    ├── viewmodel/       # Gerenciamento de estado
    └── widgets/         # Componentes específicos
Exemplo: Feature auth/
Subpasta	Finalidade	Exemplos
data/models/	Modelos da API	user_model.dart
domain/entities/	Regras de negócio	user_entity.dart
presentation/view/	UI	login_screen.dart
3. app/
Configurações globais

Arquivo	Finalidade
app.dart	Configuração inicial do MaterialApp
routes.dart	Rotas nomeadas
theme.dart	Temas e estilos globais
🔄 Fluxo de Dependências
mermaid
Copy
flowchart LR
    A[Presentation] -->|Chama| B[Domain]
    B -->|Implementado por| C[Data]
    C -->|Consome| D[(APIs/DB)]
Regra:
Presentation → Domain ← Data
(Nunca Data → Presentation)

🛠️ Como Adicionar uma Nova Feature
Crie a estrutura básica dentro de features/:

bash
Copy
mkdir -p lib/src/features/nova_feature/{data,domain,presentation}
Siga o padrão MVVM:

ViewModel chama UseCase (Domain)

UseCase usa Repository (Interface)

RepositoryImpl (Data) acessa fontes externas

Registre as rotas em app/routes.dart

📌 Boas Práticas
✅ 1 feature = 1 pasta

✅ Injeção de dependência: Use provider ou get_it

✅ Testes:

test/: Unitários (ViewModel, UseCases)

integration_test/: Telas completas

✅ Nomenclatura:

Telas: *_screen.dart

Widgets: *_widget.dart