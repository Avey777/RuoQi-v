module fms_api

import veb
import log
import json2 as json
import model.schema_fms { FmsFile }
import common.api
import model { Context }

// ═══ Handler ═══
@['/file/by_id'; post]
pub fn (app &Fms) find_fms_file_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[FmsFileByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := find_fms_file_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_fms_file_by_id_usecase(mut ctx Context, req FmsFileByIdReq) !FmsFile {
	find_fms_file_by_id_domain(req)!
	return find_fms_file_by_id_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_fms_file_by_id_domain(req FmsFileByIdReq) ! {
	if req.id == '' {
		return error('file id is required')
	}
}

// ═══ DTO ═══
pub struct FmsFileByIdReq {
	id string @[json: 'id']
}

// ═══ Repository ═══
fn find_fms_file_by_id_repo(mut ctx Context, req FmsFileByIdReq) !FmsFile {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	files := sql db {
		select from FmsFile where id == req.id limit 1
	} or { return error('Failed: ${err}') }

	if files.len == 0 {
		return error('FmsFile not found')
	}

	return files[0]
}
