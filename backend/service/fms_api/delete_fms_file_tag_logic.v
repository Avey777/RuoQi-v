module fms_api

import veb
import log
import json2 as json
import model.schema_fms { FmsFileJoinTag, FmsFileTag }
import common.api
import model { Context }

// ═══ Handler ═══
@['/tag/delete'; post]
pub fn (app &Fms) delete_fms_file_tag_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteFmsFileTagReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := delete_fms_file_tag_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn delete_fms_file_tag_usecase(mut ctx Context, req DeleteFmsFileTagReq) !DeleteFmsFileTagResp {
	delete_fms_file_tag_domain(req)!
	return delete_fms_file_tag_repo(mut ctx, req.ids)
}

// ═══ Domain ═══
fn delete_fms_file_tag_domain(req DeleteFmsFileTagReq) ! {
	if req.ids.len == 0 {
		return error('No FmsFileTag ids provided')
	}
}

// ═══ DTO ═══
pub struct DeleteFmsFileTagReq {
	ids []string @[json: 'ids']
}

pub struct DeleteFmsFileTagResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_fms_file_tag_repo(mut ctx Context, ids []string) !DeleteFmsFileTagResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		delete from FmsFileJoinTag where file_tag_id in ids
	} or { return error('Failed to delete join table rows: ${err}') }

	sql db {
		delete from FmsFileTag where id in ids
	} or { return error('Failed to delete file tag: ${err}') }

	return DeleteFmsFileTagResp{
		msg: '${ids.len} FmsFileTag(s) deleted successfully'
	}
}
