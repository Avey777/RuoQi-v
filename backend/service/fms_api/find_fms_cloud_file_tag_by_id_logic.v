module fms_api

import veb
import log
import json2 as json
import model.schema_fms { FmsCloudFileTag }
import common.api
import model { Context }

@['/cloudtag/by_id'; post]
pub fn (app &Fms) find_fms_cloud_file_tag_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FmsCloudFileTagByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := find_fms_cloud_file_tag_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

pub fn find_fms_cloud_file_tag_by_id_usecase(mut ctx Context, req FmsCloudFileTagByIdReq) !FmsCloudFileTag {
	find_fms_cloud_file_tag_by_id_domain(req)!
	return find_fms_cloud_file_tag_by_id_repo(mut ctx, req)
}

fn find_fms_cloud_file_tag_by_id_domain(req FmsCloudFileTagByIdReq) ! {
	if req.id == '' { return error('tag id is required') }
}

pub struct FmsCloudFileTagByIdReq {
	id string @[json: 'id']
}

fn find_fms_cloud_file_tag_by_id_repo(mut ctx Context, req FmsCloudFileTagByIdReq) !FmsCloudFileTag {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	tags := sql db {
		select from FmsCloudFileTag where id == req.id limit 1
	} or { return error('Failed: ${err}') }
	if tags.len == 0 { return error('FmsCloudFileTag not found') }
	return tags[0]
}
