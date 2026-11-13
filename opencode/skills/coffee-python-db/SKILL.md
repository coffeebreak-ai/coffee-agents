---
name: Coffee Python DB
description: SQLAlchemy 2.1 и Alembic: модели, сессия на запрос, репозиторий, транзакции, миграции. Не для структуры сервиса и HTTP.
---

# Coffee: база данных

Синхронный SQLAlchemy 2.1 и `psycopg` 3. Async-драйверы и `async_session` запрещены.

## Модели

```python
class Base(DeclarativeBase):
    metadata = MetaData(naming_convention={...})


class Order(Base):
    __tablename__ = "orders"
    id: Mapped[int] = mapped_column(primary_key=True)
    amount: Mapped[Decimal] = mapped_column(Numeric(38, 18))
```

* Только `DeclarativeBase`, `Mapped` и `mapped_column`. `declarative_base()` и `Query` устарели.
* Запросы — `select(...)` и `session.scalars(...)`.
* `Numeric` для денег, `timezone=True` для дат, `String` с длиной.
* `create_all` в рантайме запрещён: схему меняет только Alembic.

## Сессия

* Одна сессия на запрос: создаётся в `before_request`, кладётся в `g`, закрывается в `teardown_appcontext`.
* Фабрика сессий создаётся в `init_extensions`; `expire_on_commit=False`.
* Репозиторий получает сессию аргументом и не открывает её сам.

## Репозиторий

Три метода, как в Go-сервисах:

```python
def add_model(self, model: Order) -> Order
def find_model(self, model_id: int) -> Order | None
def update_model(self, model_id: int, partial: PartialOrder) -> Order | None
```

* `Partial` — модель с полями `| None`; `None` означает «не менять», а не «записать NULL».
* Транзакция — на уровне сервиса: `with session.begin():` вокруг нескольких операций. Репозиторий не коммитит.

## Alembic

* `migrations/` — отдельный каталог, `target_metadata = Base.metadata`.
* `naming_convention` в `MetaData` обязателен, иначе миграции не откатываются.
* `alembic revision --autogenerate` — только с последующим чтением файла: удаления и переименования проверяются руками.
* Миграции применяются вне приложения: `alembic upgrade head` в Makefile и на деплое, не при старте сервиса.
