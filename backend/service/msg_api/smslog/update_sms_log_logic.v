module smslog

import veb
import log
import time
import json2 as json
import model.schema_msg { MsgSmsLog }
import common.api
import model { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &SmsLog) update_sms_log_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateSmsLogReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_sms_log_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn update_sms_log_usecase(mut ctx Context, req UpdateSmsLogReq) !UpdateSmsLogResp {
	update_sms_log_domain(req)!
	return update_sms_log_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_sms_log_domain(req UpdateSmsLogReq) ! {
	if req.id == '' {
		return error('sms log id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateSmsLogReq {
	id           string  @[json: 'id']
	phone_number ?string @[json: 'phoneNumber']
	content      ?string @[json: 'content']
	send_status  ?u8     @[json: 'sendStatus']
	provider     ?string @[json: 'provider']
}

pub struct UpdateSmsLogResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_sms_log_repo(mut ctx Context, req UpdateSmsLogReq) !UpdateSmsLogResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	up_expr := {
		if phone_number := req.phone_number { phone_number == phone_number },
		if content := req.content { content == content },
		if send_status := req.send_status { send_status == send_status },
		if provider := req.provider { provider == provider },
		updated_at == time.now()
	}

	sql db {
		dynamic update MsgSmsLog set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateSmsLogResp{
		msg: 'SmsLog updated successfully'
	}
}
