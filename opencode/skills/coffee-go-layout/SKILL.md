---
name: Coffee Go Layout
description: Новый Go-сервис, правка слоёв handlers, services, repositories, models, errors или Makefile. Дерево каталогов и три метода репозитория.
---

# Coffee: слои

Существующие каталоги не переноси без прямой задачи. Новый сервис начинается с `Makefile` и этого дерева.

```text
/internal/handlers
/internal/handlers/http
/internal/handlers/grpc
/internal/handlers/messages/request
/internal/handlers/messages/response
/internal/services
/internal/services/structures
/internal/repositories/postgres
/internal/repositories/clickhouse
/internal/repositories/redis
/internal/config
/deployments
/migrations/postgres
/migrations/clickhouse
/docs
/errors
/models
```

* handlers — REST: валидация `messages`, сериализация, проксирование ошибки в `/errors`.
* services — бизнес. `messages` не импортирует. В репозиторий отдаёт `models`.
* repositories — только `models`. Postgres, ClickHouse и Redis не смешивать в одном файле.

## Репозиторий

```go
AddModel(ctx context.Context, m *Model) error
FindModel(ctx context.Context, filter *FilterModel) ([]Model, error)
UpdateModel(ctx context.Context, m *Model, partial *PartialModel) (*Model, error)
```

`FilterModel` и `PartialModel` — поля-указатели. `nil` значит «условие не ставить» и «колонку не менять». В `FilterModel` есть `Limit` и `Offset`; нулевые значения репозиторий заменяет своим дефолтом. `UpdateModel` возвращает модель с уже накатанным partial. Четвёртый метод «на всякий случай» не добавляй.

Две таблицы в одной операции — одна транзакция. `tx` передавай параметром в приватный метод; в поле структуры репозитория не храни. Публичные три метода не меняются.

`/errors`: стабильный код и текст (`thing-1045`). HTTP-код выбирает handler. Service и repository возвращают обычный `error`.

Интерфейс объявляй у потребителя. Конструктор принимает интерфейс и возвращает структуру. Зависимости через `New`, не через `init` и не через глобалы.

## Makefile

В корне сервиса всегда есть `Makefile`. Цель добавляй, только если сервис это умеет, и она делает ровно то, что названа:

```text
run                     локальный запуск
stop                    остановить локальный процесс
test                    go test ./...
lint                    golangci-lint run из корня
proto                   генерация кода из proto
docker-build            сборка образа
docker-stop             остановить и удалить контейнер
docker-log              логи контейнера, follow
migrate-postgres-up     миграции вверх
migrate-postgres-dn     откат одной миграции
migrate-clickhouse-up
migrate-clickhouse-dn
```

Привычные имена вроде `docker-logs` не переименовывай: недостающую цель добавь, старую оставь. Команды запуска и миграций держи в `Makefile`, не дублируй в docs и промпте.
