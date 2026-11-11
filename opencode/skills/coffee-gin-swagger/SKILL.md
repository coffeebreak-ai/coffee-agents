---
name: Coffee Gin Swagger
description: HTTP-handler на gin или правка swag-аннотаций. Не для обычной правки Go без эндпоинта.
---

# Coffee: gin и swag

HTTP — gin. Комментарий swag над методом пиши всегда: это контракт, исключение из запрета комментариев в `coffee-golang-dev` на него не действует. Набор тегов не сокращай. От echo отличается только сигнатура и раздача, нотация та же.

```go
// CreatePersonalAddressActionAddOrFullUpdateSubUser
// @title 			CreatePersonalAddressActionAddOrFullUpdate
// @summary			Start create full update personal address for sub user
// @description 	Create personal address action as (1/2) step for create or full update personal address for sub user
// @description 	This method require 2FA authorization, and contains 3 sub steps:
// @description 	* receive `secret-key` with empty request with 444 status code.
// @description 	* generate/receive `secret-values` from source depending on your profile settings.
// @description 	* fill both required headers fields for this step: `secret-key`, `secret-value`.
// @description 	* finalize request with 200 status code.
// @tags        	address
// @version			1.0
// @param 			subuser_id		path		string														true	"Authorization details for sub user, can be legacy integer id, or new uuid format."
// @security 		ApiKeyAuth
// @param       	secret-key		header 		string 														false 	"2fa secret key."
// @param       	secret-value	header 		int 														false 	"2fa secret value."
// @param 			data 			body 		request.CreatePersonalAddressActionAddOrFullUpdateRequest 	true 	"Object with required params: `network`, `address` and optional: `min_payout`, `is_disabled`. min payout must be greater default value or zero for default value."
// @success 		200 			{object} 	response.MessageResponse									"Default not empty message."
// @response		444				{object}	response.UserActionResponse									"2fa response"
// @failure			400
// @Router 			/address/create_personal_address_action_add_or_full_update/{subuser_id}	[post]
func (h *Address) CreatePersonalAddressActionAddOrFullUpdateSubUser(c *gin.Context) {}
```

Для body-запроса добавь `@Accept json` и `@Produce json` выше `@param`. Вход — `c.ShouldBindJSON`, для query и path — `c.ShouldBindQuery` и `c.ShouldBindUri`. Ответ — `c.JSON(code, response-структура)`, код и тело ошибки бери из `/errors`.

Типы тела и ответа — из `messages/request` и `messages/response`. Имя в `@security` совпадает с `@securityDefinitions` в `main.go`. Раздача: `GET /swagger/*any` через `github.com/swaggo/gin-swagger` и `github.com/swaggo/files`. Генерация из корня модуля: `swag init -g main.go --parseInternal -o internal/handlers/docs`; без `--parseInternal` типы из `internal/` в доку не попадут. Сгенерированный пакет не править руками и не класть в `/docs`.
