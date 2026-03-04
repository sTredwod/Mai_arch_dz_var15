workspace {
    name "ДЗ-01 Вариант 15 — Управление библиотекой"
    description "C4 (Structurizr DSL): C1 System Context, C2 Container, Dynamic для сценария выдачи книги"

    !identifiers hierarchical

    model {
        properties {
            architect "Ilya"
        }

        # Роли пользователей
        reader = person "Читатель" {
            description "Ищет книги и смотрит список своих выдач."
        }

        librarian = person "Библиотекарь" {
            description "Добавляет книги, оформляет выдачу и возврат."
        }

        # Внешние системы
        notify = softwareSystem "Сервис уведомлений" {
            description "Отправляет уведомления пользователям (email/SMS/мессенджер)."
        }

        identity = softwareSystem "Identity Provider" {
            description "Авторизация/аутентификация пользователей (OIDC/OAuth2)."
        }

        isbn = softwareSystem "ISBN Metadata Provider" {
            description "Внешний источник метаданных книги по ISBN (название, автор, издательство)."
        }

        # Наша система
        library_system = softwareSystem "Library Management System" {
            description "Система управления библиотекой: пользователи, книги, выдачи/возвраты."

            # Хранилище
            db = container "База данных" {
                technology "PostgreSQL"
                tags "db"
                description "Хранение данных: User, Book, Loan."
            }

            # Поиск
            search = container "Search Index" {
                technology "Elasticsearch"
                tags "search"
                description "Индекс для быстрого поиска книг (по названию/автору/ISBN)."
            }

            # Сервисы (контейнерный уровень)
            user_service = container "User Service" {
                technology "Java 17 (Spring Boot)"
                tags "java"
                description "Создание/поиск пользователей."

                -> db "CRUD пользователей" "JDBC/SQL TCP:5432"
            }

            catalog_service = container "Catalog Service" {
                technology "Java 17 (Spring Boot)"
                tags "java"
                description "Добавление/поиск книг, обновление карточек."

                -> db "CRUD книг" "JDBC/SQL TCP:5432"
                -> search "Обновление индекса поиска" "REST HTTPS:443"
                -> isbn "Загрузка метаданных по ISBN" "REST HTTPS:443"
            }

            loan_service = container "Loan Service" {
                technology "Java 17 (Spring Boot)"
                tags "java"
                description "Выдача/возврат, список выданных книг пользователю."

                -> db "CRUD выдач/возвратов, статус книги" "JDBC/SQL TCP:5432"
                -> notify "Уведомления о выдаче/сроке возврата" "REST HTTPS:443"
            }

            # Backend entrypoint (после сервисов, чтобы ссылки работали)
            api_gateway = container "API Gateway / BFF" {
                technology "Java 17 (Spring Boot)"
                tags "java"
                description "Единая точка входа для UI, маршрутизация запросов в сервисы."

                -> identity "Проверка токена/логин" "OIDC HTTPS:443"
                -> user_service "Запросы по пользователям" "REST HTTPS:443"
                -> catalog_service "Запросы по книгам/поиску" "REST HTTPS:443"
                -> loan_service "Запросы по выдачам" "REST HTTPS:443"
            }

            # UI
            reader_web = container "Reader Web UI" {
                technology "React"
                tags "web"
                description "Интерфейс читателя: поиск книг, просмотр своих выдач."
            }

            staff_web = container "Staff Web UI" {
                technology "React"
                tags "web"
                description "Интерфейс библиотекаря: добавление книг, выдача/возврат."
            }

            # Связи UI -> gateway
            reader_web -> api_gateway "REST API (читатель)" "REST HTTPS:443"
            staff_web  -> api_gateway "REST API (библиотекарь)" "REST HTTPS:443"
        }

        # Связи людей -> UI (чтобы C1 был понятнее)
        reader -> library_system.reader_web "Поиск книг, просмотр своих выдач" "HTTPS:443"
        librarian -> library_system.staff_web "Добавление книг, выдача/возврат" "HTTPS:443"
    }

    views {
        properties {
            structurizr.sort created
            structurizr.tooltips true
        }

        themes default

        # C1: Контекст
        systemContext library_system "C1" {
            include *
            autoLayout
        }

        # C2: Контейнеры
        container library_system "C2" {
            include *
            autoLayout
        }

        # Dynamic: сценарий "Выдача книги пользователю"
        dynamic library_system "D1_IssueBook" {
            librarian -> library_system.staff_web "Оформляет выдачу книги" "HTTPS:443"
            library_system.staff_web -> library_system.api_gateway "POST /loans" "REST HTTPS:443"

            library_system.api_gateway -> identity "Проверка токена" "OIDC HTTPS:443"
            library_system.api_gateway -> library_system.user_service "GET /users/{id}" "REST HTTPS:443"
            library_system.api_gateway -> library_system.catalog_service "GET /books/{id} (проверка доступности)" "REST HTTPS:443"
            library_system.api_gateway -> library_system.loan_service "POST /loans (создать выдачу)" "REST HTTPS:443"

            library_system.loan_service -> library_system.db "INSERT loan + UPDATE book status" "JDBC/SQL TCP:5432"
            library_system.loan_service -> notify "Уведомление пользователю" "REST HTTPS:443"
            autoLayout
        }
    }
}