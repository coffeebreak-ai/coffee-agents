---
name: "Coffee C#"
description: Пишешь или рефакторишь C# и .NET. Nullable, async и CancellationToken, decimal, EF Core, DI, анализаторы. Не для структуры решения и фреймворков.
disable-model-invocation: true
---

# Coffee: C#

Целевой TFM и версию C# бери из `.csproj`; новый проект — текущий LTS. Пакеты, TFM и `Directory.Build.props` не меняй без прямой просьбы. Локальный `AGENTS.md` и принятая структура решения важнее.

Nullable reference types включены. `!` — только там, где инвариант доказан; иначе проверка и `ArgumentNullException.ThrowIfNull`. DTO и ответы — `record`; доменные модели не отдавай наружу, маппинг в DTO. `async`-методы получают `CancellationToken` и передают его в каждый вызов; `.Result`, `.Wait()` и `GetAwaiter().GetResult()` запрещены, `Task.Run` — не замена async для I/O. `using`/`await using` для всего `IDisposable`/`IAsyncDisposable`.

HTTP — `IHttpClientFactory` или типизированный клиент, не `new HttpClient()` на вызов; таймаут явный. Повторы и circuit breaker — через resilience handler, только для идемпотентных операций. Ожидаемые бизнес-ошибки — исключение своего типа или `Result`, если он уже принят в проекте; общий `catch` с проглатыванием запрещён. Лог — `ILogger` со структурными полями и ID сущности.

EF Core: только async-методы, чтение — `AsNoTracking`, проекция в DTO, без ленивой загрузки; `IQueryable` не выноси за границу репозитория. Транзакции явные. Миграции генерируй и просматривай; неразрушающую применяй, деструктивную — только с подтверждением.

Деньги и точные расчёты — `decimal`, не `double`/`float`; точность и округление — из контракта. Даты — `DateTimeOffset` в UTC. DI — через конструктор, без service locator и `new` для сервисов; настройки — `IOptions<T>`, секреты — из конфигурации и окружения. Коллекции наружу — `IReadOnlyList<T>`, несколько перечислений одного `IEnumerable` не допускай.

## Проверка

`dotnet build` (предупреждения анализаторов — ошибки, если так настроено), `dotnet test`, при настроенном форматтере — `dotnet format --verify-no-changes`. Замечания правь в коде, конфиги — только по прямой просьбе. Комментарии и XML-doc — только по прямой просьбе.
