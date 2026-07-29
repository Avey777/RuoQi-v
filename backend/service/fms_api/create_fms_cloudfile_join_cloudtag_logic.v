module fms_api

import veb
import log
import json2 as json
import model.schema_fms { FmsCloudFileCloudFileTag }
import common.api
import model { Context }

@['/cloudfile_tag/create'; post]
pub fn (app &Fms) create_fms_cloudfile_join_cloudtag_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[CreateFmsCloudFileCloudFileTagReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := create_fms_cloudfile_join_cloudtag_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

pub fn create_fms_cloudfile_join_cloudtag_usecase(mut ctx Context, req CreateFmsCloudFileCloudFileTagReq) !CreateFmsCloudFileCloudFileTagResp {
	create_fms_cloudfile_join_cloudtag_domain(req)!
	return create_fms_cloudfile_join_cloudtag_repo(mut ctx, req)
}

fn create_fms_cloudfile_join_cloudtag_domain(req CreateFmsCloudFileCloudFileTagReq) ! {
	if req.cloud_file_tag_id == '' { return error('cloud file tag id is required') }
	if req.cloud_file_id == '' { return error('cloud file id is required') }
}

pub struct CreateFmsCloudFileCloudFileTagReq {
	cloud_file_tag_id string @[json: 'cloudFileTagId']
	cloud_file_id     string @[json: 'cloudFileId']
}

pub struct CreateFmsCloudFileCloudFileTagResp {
	msg string @[json: 'msg']
}

fn create_fms_cloudfile_join_cloudtag_repo(mut ctx Context, req CreateFmsCloudFileCloudFileTagReq) !CreateFmsCloudFileCloudFileTagResp {
	join := FmsCloudFileCloudFileTag{
		cloud_file_tag_id: req.cloud_file_tag_id
		cloud_file_id:     req.cloud_file_id
	}
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		insert join into FmsCloudFileCloudFileTag
	} or { return error('Failed: ${err}') }
	return CreateFmsCloudFileCloudFileTagResp{
		msg: 'Cloud file-tag link created successfully'
	}
}
