module smsprovider

import veb
import log
import json2 as json
import model.schema_msg { MsgSmsProvider }
import common.api
import model { Context }

// ═══ Handler ═══
@['/delete'; post]
pub fn (app &SmsProvider) delete_sms_provider_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteSmsProviderReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := delete_sms_provider_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn delete_sms_provider_usecase(mut ctx Context, req DeleteSmsProviderReq) !DeleteSmsProviderResp {
	delete_sms_provider_domain(req)!
	return delete_sms_provider_repo(mut ctx, req.ids)
}

// ═══ Domain ═══
fn delete_sms_provider_domain(req DeleteSmsProviderReq) ! {
	if req.ids.len == 0 {
		return error('No SmsProvider ids provided')
	}
}

// ═══ DTO ═══
pub struct DeleteSmsProviderReq {
	ids []string @[json: 'ids']
}

pub struct DeleteSmsProviderResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_sms_provider_repo(mut ctx Context, ids []string) !DeleteSmsProviderResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		delete from MsgSmsProvider where id in ids
	} or { return error('Failed to delete sms provider: ${err}') }

	return DeleteSmsProviderResp{
		msg: '${ids.len} SmsProvider(s) deleted successfully'
	}
}
