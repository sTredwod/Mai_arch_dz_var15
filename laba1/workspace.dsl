workspace {
    name "ДЗ-01 Вариант 15 — Управление библиотекой"
    description "Документирование архитектуры в Structurizr: C1, C2 и 1 Dynamic (выдача книги)"

    !identifiers hierarchical

    model {
        properties {
            architect "Ilya"
        }

        // Роли
        reader = person "Читатель" {
            description "Ищет книги и просматривает список своих выдач."
        }

        librarian = person "Библиотекарь" {
            description "Добавляет книги, оформляет выдачу и возврат."
        }

        // Внешние системы
        notify = softwareSystem "Сервис уведомлений" {
            description "Внешний сервис отправки уведомлений (email/SMS/мессенджер)."
            tags "External"
        }

        identity = softwareSystem "Identity Provider" {
            description "Внешний провайдер авторизации/аутентификации (OIDC/OAuth2)."
            tags "External"
        }

        isbn = softwareSystem "ISBN Metadata Provider" {
            description "Внешний источник метаданных книги по ISBN (название, автор, издательство)."
            tags "External"
        }

        // Основная система (вариант 15)
        library_system = softwareSystem "Library Management System" {
            description "Система управления библиотекой: пользователи, книги, выдачи/возвраты."

            # UI
            reader_web = container "Reader Web UI" {
                technology "Web UI (React)"
                tags "web"
                description "Поиск книг, просмотр своих выдач."
            }

            staff_web = container "Staff Web UI" {
                technology "Web UI (React)"
                tags "web"
                description "Добавление книг, выдача/возврат."
            }

            // Точка входа
            api_gateway = container "API Gateway / BFF" {
                technology "Java 17 (Spring Boot)"
                tags "java"
                description "Единая точка входа для UI: маршрутизация запросов в сервисы."
            }

            // Сервисы на контейнерном уровне
            user_service = container "User Service" {
                technology "Java 17 (Spring Boot)"
                tags "java"
                description "Создание пользователя, поиск пользователя."
            }

            catalog_service = container "Catalog Service" {
                technology "Java 17 (Spring Boot)"
                tags "java"
                description "Добавление книги, поиск книг."
            }

            loan_service = container "Loan Service" {
                technology "Java 17 (Spring Boot)"
                tags "java"
                description "Создание выдачи, список выданных книг пользователю, возврат книги."
            }

            # Хранилища
            db = container "Database" {
                technology "PostgreSQL"
                tags "db"
                description "Хранение: User, Book, Loan."
            }

            search = container "Search Index" {
                technology "Elasticsearch"
                tags "search"
                description "Индекс для быстрого поиска книг."
            }

            # Связи UI - BFF
            reader_web -> api_gateway "Запросы читателя" "REST HTTPS:443"
            staff_web  -> api_gateway "Запросы библиотекаря" "REST HTTPS:443"

            # BFF - внешняя авторизация
            api_gateway -> identity "Проверка токена/логин" "OIDC HTTPS:443"

            # BFF -> сервисы
            api_gateway -> user_service "API пользователей (/users/*)" "REST HTTPS:443"
            api_gateway -> catalog_service "API книг и поиска (/books/*)" "REST HTTPS:443"
            api_gateway -> loan_service "API выдач/возвратов (/loans/*)" "REST HTTPS:443"

            # Сервисы - хранилища / интеграции
            user_service -> db "Данные пользователей" "JDBC/SQL TCP:5432"

            catalog_service -> db "Данные книг" "JDBC/SQL TCP:5432"
            catalog_service -> search "Обновление индекса поиска" "REST HTTPS:443"
            catalog_service -> isbn "Загрузка метаданных по ISBN" "REST HTTPS:443"

            loan_service -> db "Данные выдач и статусы книг" "JDBC/SQL TCP:5432"
            loan_service -> notify "Уведомление о выдаче/сроке возврата" "REST HTTPS:443"
        }

        # Люди - UI (для понятного C1)
        reader -> library_system.reader_web "Ищет книги, смотрит свои выдачи" "HTTPS:443"
        librarian -> library_system.staff_web "Добавляет книги, оформляет выдачу/возврат" "HTTPS:443"
    }

    views {
        properties {
            structurizr.sort created
            structurizr.tooltips true
            plantuml.format "svg"
            kroki.format "svg"
        }

        themes default

        # C1
        systemContext library_system "C1-SystemContext" {
            include reader
            include librarian
            include library_system
            include notify
            include identity
            include isbn
            autolayout lr
            title "C1 – Контекст системы: библиотека"
            description "Читатель и библиотекарь взаимодействуют с системой через веб-интерфейсы. Система интегрируется с внешним провайдером авторизации, источником метаданных по ISBN и сервисом уведомлений."
        }

        # C2
        container library_system "C2-Containers" {
            include *
            autolayout lr
            title "C2 – Диаграмма контейнеров: библиотека"
            description "Контейнеры покрывают операции варианта 15: пользователи, книги и выдачи/возвраты. Указаны технологии контейнеров и протоколы взаимодействия."
        }

        # D1 
        dynamic library_system "D1-IssueBook" {
            title "D1 – Динамика: выдача книги пользователю"
            description "Библиотекарь оформляет выдачу. Система проверяет токен, получает пользователя и книгу, создаёт выдачу, обновляет статус книги и отправляет уведомление."

            librarian -> library_system.staff_web "Оформляет выдачу книги" "HTTPS:443"
            library_system.staff_web -> library_system.api_gateway "POST /loans {userId, bookId}" "REST HTTPS:443"

            library_system.api_gateway -> identity "Проверка токена" "OIDC HTTPS:443"
            identity -> library_system.api_gateway "OK (token valid)" "OIDC HTTPS:443"

            library_system.api_gateway -> library_system.user_service "GET /users/{id}" "REST HTTPS:443"
            library_system.user_service -> library_system.api_gateway "200 OK (user)" "REST HTTPS:443"

            library_system.api_gateway -> library_system.catalog_service "GET /books/{id} (availability)" "REST HTTPS:443"
            library_system.catalog_service -> library_system.api_gateway "200 OK (book available)" "REST HTTPS:443"

            library_system.api_gateway -> library_system.loan_service "POST /loans" "REST HTTPS:443"
            library_system.loan_service -> library_system.db "INSERT loan + UPDATE book status" "JDBC/SQL TCP:5432"
            library_system.loan_service -> notify "Notify(userId, dueDate)" "REST HTTPS:443"

            library_system.loan_service -> library_system.api_gateway "200 OK {loanId}" "REST HTTPS:443"
            library_system.api_gateway -> library_system.staff_web "200 OK {loanId}" "REST HTTPS:443"

            autolayout lr
        }
    }
}
