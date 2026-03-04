workspace {
    name "ДЗ-01 Вариант 15 — Управление библиотекой"
    description "C4 (Structurizr DSL): System Context (C1), Container (C2), Dynamic для сценария выдачи книги"

    # включаем режим с иерархической системой идентификаторов
    !identifiers hierarchical

    model {
        properties {
            architect "Ilya"
        }

        # Роли пользователей
        reader    = person "Читатель" "Ищет книги и смотрит список своих выдач."
        librarian = person "Библиотекарь" "Добавляет книги, оформляет выдачу и возврат."

        # Внешняя система (пример)
        notify = softwareSystem "Сервис уведомлений" {
            description "Отправка уведомлений пользователям (email/SMS/мессенджер)."
        }

        # Наша система (вариант 15)
        library_system = softwareSystem "Library Management System" {
            description "Система управления библиотекой: пользователи, книги, выдачи."

            db = container "База данных" {
                technology "PostgreSQL"
                tags "db"
                description "Хранение данных: User, Book, Loan."
            }

            api = container "Backend API" {
                technology "Java 17 (например, Spring Boot)"
                tags "java"
                description "REST API и бизнес-логика (пользователи, книги, выдачи/возвраты)."

                -> db "Чтение/запись: пользователи, книги, выдачи" "JDBC/SQL TCP:5432"
                -> notify "Отправка уведомлений (выдача/срок возврата)" "REST HTTPS:443"
            }

            web = container "Web-приложение" {
                technology "Web UI (например, React)"
                tags "web"
                description "Интерфейс читателя и библиотекаря."
            }

            web -> api "Вызовы REST API" "REST HTTPS:443"
        }

        # Связи пользователей с системой (через Web)
        reader -> library_system.web "Поиск книг, просмотр своих выдач" "HTTPS:443"
        librarian -> library_system.web "Добавление книг, выдача/возврат" "HTTPS:443"
    }

    views {
        # настройки отображения
        properties {
            structurizr.sort created
            structurizr.tooltips true
        }

        themes default

        # C1: Диаграмма контекста
        systemContext library_system "C1" {
            include *
            autoLayout
        }

        # C2: Диаграмма контейнеров
        container library_system "C2" {
            include *
            autoLayout
        }

        # Dynamic: сценарий "Выдача книги пользователю"
        dynamic library_system "D1_IssueBook" {
            librarian -> library_system.web "Оформляет выдачу книги (в UI)" "HTTPS:443"
            library_system.web -> library_system.api "POST /loans (создать выдачу)" "REST HTTPS:443"
            library_system.api -> library_system.db "Проверка доступности + запись выдачи + обновление статуса книги" "JDBC/SQL TCP:5432"
            library_system.api -> notify "Уведомление пользователю о выдаче и сроке возврата" "REST HTTPS:443"
            autoLayout
        }
    }
}