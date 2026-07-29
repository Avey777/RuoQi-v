module fms_api

import veb
import log
import time
import json2 as json
import model.schema_fms { FmsCloudFile }
import common.api
import model { Context }

// ═══ Handler ═══
@['/cloudfile/update'; post]
pub fn (app &Fms) update_fms_cloud_file_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateFmsCloudFileReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_fms_cloud_file_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn update_fms_cloud_file_usecase(mut ctx Context, req UpdateFmsCloudFileReq) !UpdateFmsCloudFileResp {
	update_fms_cloud_file_domain(req)!
	return update_fms_cloud_file_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_fms_cloud_file_domain(req UpdateFmsCloudFileReq) ! {
	if req.id == '' {
		return error('cloud file id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateFmsCloudFileReq {
	id                           string  @[json: 'id']
	name                         ?string @[json: 'name']
	url                          ?string @[json: 'url']
	file_type                    ?u8     @[json: 'fileType']
	cloud_file_storage_providers ?string @[json: 'cloudFileStorageProviders']
	status                       ?u8     @[json: 'status']
}

pub struct UpdateFmsCloudFileResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_fms_cloud_file_repo(mut ctx Context, req UpdateFmsCloudFileReq) !UpdateFmsCloudFileResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	up_expr := {
		if name := req.name { name == name },
		if url := req.url { url == url },
		if file_type := req.file_type { file_type == file_type },
		if cloud_file_storage_providers := req.cloud_file_storage_providers {
			cloud_file_storage_providers == cloud_file_storage_providers
		},
		if status := req.status { status == status },
		updated_at == time.now()
	}

	sql db {
		dynamic update FmsCloudFile set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateFmsCloudFileResp{
		msg: 'FmsCloudFile updated successfully'
	}
}
