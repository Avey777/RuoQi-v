module fms_api

import veb
import log
import json2 as json
import model.schema_fms { FmsCloudFile }
import common.api
import model { Context }

// ═══ Handler ═══
@['/cloudfile/delete'; post]
pub fn (app &Fms) delete_fms_cloud_file_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteFmsCloudFileReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := delete_fms_cloud_file_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn delete_fms_cloud_file_usecase(mut ctx Context, req DeleteFmsCloudFileReq) !DeleteFmsCloudFileResp {
	delete_fms_cloud_file_domain(req)!
	return delete_fms_cloud_file_repo(mut ctx, req.ids)
}

// ═══ Domain ═══
fn delete_fms_cloud_file_domain(req DeleteFmsCloudFileReq) ! {
	if req.ids.len == 0 {
		return error('No FmsCloudFile ids provided')
	}
}

// ═══ DTO ═══
pub struct DeleteFmsCloudFileReq {
	ids []string @[json: 'ids']
}

pub struct DeleteFmsCloudFileResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_fms_cloud_file_repo(mut ctx Context, ids []string) !DeleteFmsCloudFileResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		delete from FmsCloudFile where id in ids
	} or { return error('Failed to delete cloud file: ${err}') }

	return DeleteFmsCloudFileResp{
		msg: '${ids} FmsCloudFile(s) deleted successfully'
	}
}
