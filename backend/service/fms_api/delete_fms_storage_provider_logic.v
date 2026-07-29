module fms_api

import veb
import log
import json2 as json
import model.schema_fms { FmsStorageProvider }
import common.api
import model { Context }

@['/provider/delete'; post]
pub fn (app &Fms) delete_fms_storage_provider_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[DeleteFmsStorageProviderReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := delete_fms_storage_provider_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

pub fn delete_fms_storage_provider_usecase(mut ctx Context, req DeleteFmsStorageProviderReq) !DeleteFmsStorageProviderResp {
	delete_fms_storage_provider_domain(req)!
	return delete_fms_storage_provider_repo(mut ctx, req.ids)
}

fn delete_fms_storage_provider_domain(req DeleteFmsStorageProviderReq) ! {
	if req.ids.len == 0 { return error('No FmsStorageProvider ids provided') }
}

pub struct DeleteFmsStorageProviderReq {
	ids []string @[json: 'ids']
}

pub struct DeleteFmsStorageProviderResp {
	msg string @[json: 'msg']
}

fn delete_fms_storage_provider_repo(mut ctx Context, ids []string) !DeleteFmsStorageProviderResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		delete from FmsStorageProvider where id in ids
	} or { return error('Failed: ${err}') }
	return DeleteFmsStorageProviderResp{
		msg: '${ids} FmsStorageProvider(s) deleted successfully'
	}
}
