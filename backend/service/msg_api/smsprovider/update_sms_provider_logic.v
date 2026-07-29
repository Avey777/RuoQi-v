module smsprovider

import veb
import log
import time
import json2 as json
import model.schema_msg { MsgSmsProvider }
import common.api
import model { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &SmsProvider) update_sms_provider_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateSmsProviderReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_sms_provider_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn update_sms_provider_usecase(mut ctx Context, req UpdateSmsProviderReq) !UpdateSmsProviderResp {
	update_sms_provider_domain(req)!
	return update_sms_provider_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_sms_provider_domain(req UpdateSmsProviderReq) ! {
	if req.id == '' {
		return error('sms provider id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateSmsProviderReq {
	id         string  @[json: 'id']
	name       ?string @[json: 'name']
	secret_id  ?string @[json: 'secretId']
	secret_key ?string @[json: 'secretKey']
	region     ?string @[json: 'region']
	is_default ?u8     @[json: 'isDefault']
}

pub struct UpdateSmsProviderResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_sms_provider_repo(mut ctx Context, req UpdateSmsProviderReq) !UpdateSmsProviderResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	up_expr := {
		if name := req.name { name == name },
		if secret_id := req.secret_id { secret_id == secret_id },
		if secret_key := req.secret_key { secret_key == secret_key },
		if region := req.region { region == region },
		if is_default := req.is_default { is_default == is_default },
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}

	sql db {
		dynamic update MsgSmsProvider set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateSmsProviderResp{
		msg: 'SmsProvider updated successfully'
	}
}
