workspace "DZ-01 Variant 15 - Library" "C4 model for library management system" {

    model {
        person reader "Читатель" "Ищет книги и смотрит свои выдачи."
        person librarian "Библиотекарь" "Добавляет книги, оформляет выдачу и возврат."

        softwareSystem library "Library Management System" "Система управления библиотекой." {
            // containers добавим на следующем шаге
        }

        reader -> library "Ищет книги, смотрит свои выдачи"
        librarian -> library "Добавляет книги, оформляет выдачу/возврат"
    }

    views {
        systemContext library "C1" {
            include *
            autolayout lr
        }

        // контейнеры (C2) и dynamic добавим далее

        styles {
            element "Person" {
                shape person
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
        }
    }
}