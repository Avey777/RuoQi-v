module fms_api

import veb
import log
import json2 as json
import model.schema_fms { FmsStorageProvider }
import common.api
import model { Context }

@['/provider/by_id'; post]
pub fn (app &Fms) find_fms_storage_provider_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FmsStorageProviderByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := find_fms_storage_provider_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

pub fn find_fms_storage_provider_by_id_usecase(mut ctx Context, req FmsStorageProviderByIdReq) !FmsStorageProvider {
	find_fms_storage_provider_by_id_domain(req)!
	return find_fms_storage_provider_by_id_repo(mut ctx, req)
}

fn find_fms_storage_provider_by_id_domain(req FmsStorageProviderByIdReq) ! {
	if req.id == '' { return error('provider id is required') }
}

pub struct FmsStorageProviderByIdReq {
	id string @[json: 'id']
}

fn find_fms_storage_provider_by_id_repo(mut ctx Context, req FmsStorageProviderByIdReq) !FmsStorageProvider {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	providers := sql db {
		select from FmsStorageProvider where id == req.id limit 1
	} or { return error('Failed: ${err}') }
	if providers.len == 0 { return error('FmsStorageProvider not found') }
	return providers[0]
}
