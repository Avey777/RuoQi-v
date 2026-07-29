module tasklog

import veb
import log
import json2 as json
import model.schema_job { JobTaskLog }
import common.api
import model { Context }

// ═══ Handler ═══
@['/delete'; post]
pub fn (app &TaskLog) delete_task_log_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteTaskLogReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := delete_task_log_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn delete_task_log_usecase(mut ctx Context, req DeleteTaskLogReq) !DeleteTaskLogResp {
	delete_task_log_domain(req)!
	return delete_task_log_repo(mut ctx, req.ids)
}

// ═══ Domain ═══
fn delete_task_log_domain(req DeleteTaskLogReq) ! {
	if req.ids.len == 0 {
		return error('No TaskLog ids provided')
	}
}

// ═══ DTO ═══
pub struct DeleteTaskLogReq {
	ids []string @[json: 'ids']
}

pub struct DeleteTaskLogResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_task_log_repo(mut ctx Context, ids []string) !DeleteTaskLogResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		delete from JobTaskLog where id in ids
	} or { return error('Failed to delete task log: ${err}') }

	return DeleteTaskLogResp{
		msg: '${ids} TaskLog(s) deleted successfully'
	}
}
