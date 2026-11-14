---
name: Coffee TypeScript
description: Пишешь или рефакторишь TypeScript. strict, unknown вместо any, discriminated unions, tsc, async и ошибки. Не для структуры каталогов и фреймворков.
disable-model-invocation: true
---

# Coffee: TypeScript

Локальный `AGENTS.md`, `tsconfig.json` и уже принятые каталоги важнее. Строгость конфига не ослабляй: `strict`, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, `noImplicitOverride` — как задано в проекте. Новый проект начинай со `strict`.

`any` запрещён. На границе (JSON, ответ API, `catch`, `unknown`) — `unknown` и явная проверка: type guard, схема проекта или ручной разбор. `as` — только после проверки; `as unknown as` запрещён. Для литералов — `satisfies`, не `as`.

Состояния — discriminated union по `status`/`kind` и исчерпывающий `switch` с `never` в `default`. Из двух форм выбирай ту, что уже принята в проекте; `enum` не добавляй — `as const` и union-тип. Идентификаторы разных сущностей не смешивай: branded-тип, если он уже есть в проекте.

Типы и значения разделяй: `import type` для типов, импорты совместимы с `verbatimModuleSyntax`. Экспортируемым функциям — явный тип возврата, локально хватает вывода. Сгенерированные типы не правь руками: меняй источник генерации.

Асинхронность и ошибки — как в JavaScript: только `async/await`, без висящих Promise, `try/catch` для ожидаемых ошибок, `new Error("действие", { cause })`, без строк и пустых `catch`. `fetch` с таймаутом и проверкой `response.ok`. Деньги — целые в минимальных единицах или decimal-библиотека, не `number`.

## Проверка

Перед сдачей — `tsc --noEmit` или `npm run typecheck`, затем линтер проекта (`npm run lint`, без скрипта — `npx eslint .`). Замечания правь в коде; `tsconfig.json`, зависимости и lock-файл меняй только по прямой просьбе. Комментарии и JSDoc — только по прямой просьбе.
