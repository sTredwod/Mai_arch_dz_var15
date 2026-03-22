Да, можно сделать README в таком же духе. У одногруппницы README действительно построен как учебный отчёт: с разделами про задание, результат, вариант, архитектуру, тестирование, HTTP-коды, OpenAPI, хранилище и запуск. В самом тексте задания внутри README у неё отдельно перечислены требования про минимум 5 endpoint-ов, аутентификацию, middleware, OpenAPI/Swagger и простые тесты. ([GitHub][1])

Ниже даю тебе **готовый подробный `README.md`** под твою лабу, уже в похожей структуре, но под твой вариант — библиотечный сервис на Yandex userver.

````md
# Домашнее задание 02: Разработка REST API сервиса

Цель работы: получить практические навыки разработки REST API сервиса с использованием принципов REST, обработки HTTP-запросов, реализации аутентификации, middleware и документирования API.

## Содержание

- Домашнее задание 02: Разработка REST API сервиса, выполнил Губенков Илья 105 гр.
  - Задание
  - Результат
  - Вариант 15 – Библиотечный сервис
  - Архитектура
    - POST /users
    - GET /users
    - POST /auth/login
    - POST /books
    - GET /books
    - POST /loans
    - GET /loans
    - PATCH /loans/{loan_id}/return
  - Аутентификация
  - Middleware
  - Тестирование
  - HTTP статус-коды
  - OpenAPI
  - Хранилище
  - Запуск
    - Локальный запуск в userver-контейнере
    - Запуск через Docker Compose
  - Ограничения текущей реализации

## Задание

В рамках лабораторной работы требовалось:

1. Спроектировать REST API для выбранной предметной области.
2. Реализовать REST API сервис на выбранном языке и фреймворке.
3. Реализовать минимум 5 API endpoint-ов.
4. Реализовать простую аутентификацию.
5. Защитить минимум 2 endpoint с помощью аутентификации.
6. Добавить middleware для проверки аутентификации.
7. Создать OpenAPI/Swagger спецификацию.
8. Подготовить простые тесты успешных и ошибочных сценариев.
9. Подготовить Docker-совместимый запуск сервиса.

## Результат

Реализован REST API сервис библиотеки на **C++20** с использованием **Yandex userver**.

Сервис поддерживает:

- создание пользователя;
- поиск пользователя по логину;
- поиск пользователя по маске имени и фамилии;
- логин пользователя и получение токена;
- добавление книги;
- поиск книги по названию;
- поиск книги по автору;
- оформление выдачи книги пользователю;
- получение списка активных выдач пользователя;
- возврат книги.

Также реализованы:

- Bearer token аутентификация;
- middleware для проверки токена;
- OpenAPI спецификация;
- smoke-тесты и error-тесты;
- запуск через Docker и Docker Compose.

## Вариант 15 – Библиотечный сервис

Приложение содержит следующие основные сущности:

- **Пользователь**
- **Книга**
- **Выдача книги**

Реализованы следующие операции:

- создание нового пользователя;
- поиск пользователя по логину;
- поиск пользователя по маске имени и фамилии;
- добавление новой книги;
- поиск книги по названию;
- поиск книги по автору;
- выдача книги пользователю;
- просмотр списка активных выдач пользователя;
- возврат книги.

## Архитектура

Сервис реализован как один backend на **Yandex userver**.

Основные части проекта:

- `src/models` — модели предметной области:
  - `User`
  - `Book`
  - `Loan`
- `src/storage` — in-memory хранилище и компонент userver:
  - `LibraryStorage`
  - `LibraryStorageComponent`
- `src/handlers` — HTTP handler-ы
- `src/middlewares` — middleware для проверки Bearer token
- `configs` — конфигурация userver
- `tests` — bash-скрипты для smoke/error тестирования
- `openapi.yaml` — спецификация API
- `Dockerfile`, `docker-compose.yaml` — контейнеризация

В текущей реализации используется **in-memory storage**, то есть данные существуют только во время работы процесса.

### POST /users

Создание нового пользователя.

Request:

```json
{
  "login": "reader1",
  "password": "12345",
  "first_name": "Ilya",
  "last_name": "Ivanov"
}
````

Response:

```json
{
  "id": 1,
  "login": "reader1",
  "first_name": "Ilya",
  "last_name": "Ivanov"
}
```

### GET /users

Поиск пользователя.

Поиск по логину:

```text
GET /users?login=reader1
```

Response:

```json
{
  "id": 1,
  "login": "reader1",
  "first_name": "Ilya",
  "last_name": "Ivanov"
}
```

Поиск по маске имени/фамилии:

```text
GET /users?name_mask=Ily
```

Response:

```json
[
  {
    "id": 1,
    "login": "reader1",
    "first_name": "Ilya",
    "last_name": "Ivanov"
  }
]
```

### POST /auth/login

Логин пользователя и получение токена.

Request:

```json
{
  "login": "reader1",
  "password": "12345"
}
```

Response:

```json
{
  "token": "token-1-1"
}
```

### POST /books

Добавление новой книги.

Требует авторизацию.

Headers:

```text
Authorization: Bearer token-1-1
```

Request:

```json
{
  "title": "Master and Margarita",
  "author": "Mikhail Bulgakov",
  "total_copies": 3
}
```

Response:

```json
{
  "id": 1,
  "title": "Master and Margarita",
  "author": "Mikhail Bulgakov",
  "total_copies": 3,
  "available_copies": 3
}
```

### GET /books

Поиск книги.

По названию:

```text
GET /books?title=Master
```

По автору:

```text
GET /books?author=Bulgakov
```

Response:

```json
[
  {
    "id": 1,
    "title": "Master and Margarita",
    "author": "Mikhail Bulgakov",
    "total_copies": 3,
    "available_copies": 3
  }
]
```

### POST /loans

Оформление выдачи книги пользователю.

Требует авторизацию.

Headers:

```text
Authorization: Bearer token-1-1
```

Request:

```json
{
  "user_id": 1,
  "book_id": 1
}
```

Response:

```json
{
  "id": 1,
  "user_id": 1,
  "book_id": 1,
  "returned": false
}
```

### GET /loans

Получение списка активных выдач пользователя.

```text
GET /loans?user_id=1
```

Response:

```json
[
  {
    "id": 1,
    "user_id": 1,
    "book_id": 1,
    "returned": false
  }
]
```

### PATCH /loans/{loan_id}/return

Возврат книги.

Требует авторизацию.

Headers:

```text
Authorization: Bearer token-1-1
```

Пример:

```text
PATCH /loans/1/return
```

Response:

```json
{
  "id": 1,
  "user_id": 1,
  "book_id": 1,
  "returned": true
}
```

## Аутентификация

В проекте реализована простая token-based аутентификация.

Пользователь получает токен через endpoint:

```text
POST /auth/login
```

Далее токен передаётся в заголовке:

```text
Authorization: Bearer <token>
```

Защищены следующие endpoint-ы:

* `POST /books`
* `POST /loans`
* `PATCH /loans/{loan_id}/return`

## Middleware

Для проверки токена реализован отдельный middleware.

Middleware:

* перехватывает запросы к защищённым endpoint-ам;
* проверяет наличие заголовка `Authorization`;
* проверяет формат `Bearer <token>`;
* валидирует токен через `LibraryStorage`;
* в случае ошибки возвращает `401 Unauthorized`.

Таким образом, проверка аутентификации вынесена из общей логики маршрутов в отдельный слой.

## Тестирование

Для тестирования реализованы два bash-скрипта:

* `tests/smoke_tests.sh` — успешные сценарии;
* `tests/error_tests.sh` — ошибочные сценарии.

### Smoke tests

Проверяются:

* создание пользователя;
* логин;
* создание книги;
* поиск книги;
* оформление выдачи;
* получение выдач;
* возврат книги.

Запуск:

```bash
bash -x ./tests/smoke_tests.sh
```

### Error tests

Проверяются:

* запрос без обязательных query-параметров;
* логин с неверным паролем;
* доступ к защищённым endpoint-ам без токена;
* ошибки авторизации.

Запуск:

```bash
bash -x ./tests/error_tests.sh
```

## HTTP статус-коды

В сервисе используются следующие основные HTTP статус-коды:

* `200 OK` — успешный GET/логин/возврат;
* `201 Created` — успешное создание ресурса;
* `400 Bad Request` — невалидные данные или параметры запроса;
* `401 Unauthorized` — отсутствует или неверен токен, неверные учётные данные;
* `404 Not Found` — пользователь, книга или выдача не найдены;
* `409 Conflict` — конфликт состояния, например:

  * пользователь уже существует;
  * книга уже существует;
  * пользователь уже взял эту книгу;
  * книга уже возвращена;
  * книга недоступна.

## OpenAPI

Для проекта подготовлена спецификация:

```text
openapi.yaml
```

В ней описаны:

* все endpoint-ы;
* параметры запросов;
* request/response схемы;
* ошибки;
* Bearer token security scheme.

## Хранилище

Хранилище реализовано как **in-memory storage**.

Используются контейнеры в памяти процесса:

* пользователи;
* книги;
* выдачи;
* токены.

Плюсы такого решения:

* простота реализации;
* быстрый запуск;
* отсутствие внешней базы данных.

Минус:

* данные **не сохраняются между перезапусками** сервиса или контейнера.

## Запуск

### Локальный запуск в userver-контейнере

Из каталога проекта: (Именно нижнее подчеркивание! То есть /Mai_arch_dz_var15/Laba2/library-service/library_service)

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  --security-opt seccomp=unconfined \
  -p 8080:8080 \
  -v "$PWD":/work \
  -w /work \
  --entrypoint bash \
  ghcr.io/userver-framework/ubuntu-22.04-userver:latest
```

Внутри контейнера:

```bash
cd library_service
export HOME=/tmp
export CCACHE_DIR=/tmp/.ccache
mkdir -p "$CCACHE_DIR"
make build-debug
./build-debug/library_service -c configs/static_config.yaml
```

### Запуск через Docker Compose

Из каталога `library_service`: (Именно нижнее подчеркивание! То есть /Mai_arch_dz_var15/Laba2/library-service/library_service)

```bash
docker compose up --build
```

Проверка:

```bash
curl -i "http://127.0.0.1:8080/ping"
```

## Ограничения текущей реализации

* используется in-memory storage вместо PostgreSQL/SQLite;
* данные не переживают перезапуск процесса;
* токены не имеют срока жизни;
* роли пользователей не разделяются;
* не реализована полноценная бизнес-логика библиотечной системы с историей выдач и штрафами.

## Вывод

В ходе лабораторной работы был разработан REST API сервис библиотеки на C++ с использованием Yandex userver.

В проекте реализованы:

* базовые CRUD-подобные операции над сущностями;
* поиск ресурсов через query-параметры;
* простая token-based аутентификация;
* middleware для проверки авторизации;
* OpenAPI документация;
* тестовые сценарии;
* Docker-совместимый запуск.

Таким образом, требования лабораторной работы выполнены, а сервис приведён к состоянию, пригодному для демонстрации и сдачи.

```


