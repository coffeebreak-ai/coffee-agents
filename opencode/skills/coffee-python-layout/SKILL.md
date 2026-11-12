---
name: Coffee Python Layout
description: Новый Flask-сервис, слои api/services/repositories/models, фабрика create_app, настройки, Makefile. Не для правки стиля кода, OpenAPI и SQL.
---

# Coffee: слои

Существующие каталоги не переноси без прямой задачи. Новый сервис начинается с `Makefile` и этого дерева.

```text
app/
├── __init__.py          create_app
├── config.py            настройки через pydantic-settings
├── extensions.py        engine, session factory, http-клиент
├── errors.py            доменные исключения и их маппинг
├── api/v1/              blueprints
├── schemas/             Pydantic-модели
├── services/            бизнес-логика
├── repositories/        доступ к данным
└── models/              SQLAlchemy
migrations/              Alembic
tests/
pyproject.toml
Makefile
```

* `api` — валидация схем, вызов сервиса, сериализация, коды ответов.
* `services` — бизнес-логика и транзакция. Репозитории и схемы транспорта не импортирует, Flask не импортирует.
* `repositories` — только `models` и сессия.
* Слои передаются через конструктор: `Service(repo)` и `Repo(session)`.

## Фабрика

```python
def create_app(settings: Settings | None = None) -> Flask:
    app = Flask(__name__)
    app.config.from_object(settings or get_settings())
    init_extensions(app)
    register_blueprints(app)
    register_error_handlers(app)
    return app
```

* Работа на импорте запрещена: ни соединений, ни чтения окружения, ни `create_app()` на уровне модуля.
* Настройки — `Settings(BaseSettings)` с `@lru_cache` у `get_settings()`; в тестах кэш сбрасывается.
* Расширения создаются в `init_extensions` и живут в `app.extensions`, глобальных модульных переменных нет.
* Синглтон допустим только для неизменяемых объектов: настройки, engine, пул HTTP-клиента.

## Запуск

```sh
flask --app app run --debug
gunicorn 'app:create_app()' --workers 4
```

## Makefile

Цели те же, что в Go: `run`, `test`, `lint`, `migrate-up`, `migrate-dn`, `migrate-new`, `docker-build`, `docker-run`.
