module fms_api

import veb
import log
import time
import json2 as json
import model.schema_fms { FmsStorageProvider }
import common.api
import model { Context }

@['/provider/update'; post]
pub fn (app &Fms) update_fms_storage_provider_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateFmsStorageProviderReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := update_fms_storage_provider_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

pub fn update_fms_storage_provider_usecase(mut ctx Context, req UpdateFmsStorageProviderReq) !UpdateFmsStorageProviderResp {
	update_fms_storage_provider_domain(req)!
	return update_fms_storage_provider_repo(mut ctx, req)
}

fn update_fms_storage_provider_domain(req UpdateFmsStorageProviderReq) ! {
	if req.id == '' { return error('provider id is required') }
}

pub struct UpdateFmsStorageProviderReq {
	id         string  @[json: 'id']
	name       ?string @[json: 'name']
	bucket     ?string @[json: 'bucket']
	secret_id  ?string @[json: 'secretId']
	secret_key ?string @[json: 'secretKey']
	endpoint   ?string @[json: 'endpoint']
	folder     ?string @[json: 'folder']
	region     ?string @[json: 'region']
	is_default ?u8     @[json: 'isDefault']
	use_cdn    ?u8     @[json: 'useCdn']
	cdn_url    ?string @[json: 'cdnUrl']
	status     ?u8     @[json: 'status']
}

pub struct UpdateFmsStorageProviderResp {
	msg string @[json: 'msg']
}

fn update_fms_storage_provider_repo(mut ctx Context, req UpdateFmsStorageProviderReq) !UpdateFmsStorageProviderResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	existing := sql db {
		select from FmsStorageProvider where id == req.id limit 1
	} or { return error('Failed to check existence: ${err}') }
	if existing.len == 0 {
		return error('FmsStorageProvider with id ${req.id} not found')
	}

	up_expr := {
		if name := req.name { name == name },
		if bucket := req.bucket { bucket == bucket },
		if secret_id := req.secret_id { secret_id == secret_id },
		if secret_key := req.secret_key { secret_key == secret_key },
		if endpoint := req.endpoint { endpoint == endpoint },
		if folder := req.folder { folder == folder },
		if region := req.region { region == region },
		if is_default := req.is_default { is_default == is_default },
		if use_cdn := req.use_cdn { use_cdn == use_cdn },
		if cdn_url := req.cdn_url { cdn_url == cdn_url },
		if status := req.status { status == status },
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}
	sql db {
		dynamic update FmsStorageProvider set up_expr where id == req.id
	} or { return error('Failed to update storage provider: ${err}') }
	return UpdateFmsStorageProviderResp{
		msg: 'FmsStorageProvider updated successfully'
	}
}
