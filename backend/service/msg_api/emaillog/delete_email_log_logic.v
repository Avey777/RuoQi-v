module emaillog

import veb
import log
import json2 as json
import model.schema_msg { MsgEmailLog }
import common.api
import model { Context }

// ═══ Handler ═══
@['/delete'; post]
pub fn (app &EmailLog) delete_email_log_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteEmailLogReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := delete_email_log_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn delete_email_log_usecase(mut ctx Context, req DeleteEmailLogReq) !DeleteEmailLogResp {
	delete_email_log_domain(req)!
	return delete_email_log_repo(mut ctx, req.ids)
}

// ═══ Domain ═══
fn delete_email_log_domain(req DeleteEmailLogReq) ! {
	if req.ids.len == 0 {
		return error('No EmailLog ids provided')
	}
}

// ═══ DTO ═══
pub struct DeleteEmailLogReq {
	ids []string @[json: 'ids']
}

pub struct DeleteEmailLogResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_email_log_repo(mut ctx Context, ids []string) !DeleteEmailLogResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		delete from MsgEmailLog where id in ids
	} or { return error('Failed to delete email log: ${err}') }

	return DeleteEmailLogResp{
		msg: '${ids} EmailLog(s) deleted successfully'
	}
}
