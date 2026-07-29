module fms_api

import veb
import log
import model.schema_fms { FmsCloudFileCloudFileTag }
import common.api
import model { Context }
import json2 as json

@['/cloudfile_tag/all'; get]
pub fn (app &Fms) find_fms_cloudfile_join_cloudtag_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FmsCloudFileCloudFileTagListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := find_fms_cloudfile_join_cloudtag_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

pub fn find_fms_cloudfile_join_cloudtag_all_usecase(mut ctx Context, req FmsCloudFileCloudFileTagListReq) !FmsCloudFileCloudFileTagListResp {
	find_fms_cloudfile_join_cloudtag_all_domain()
	return find_fms_cloudfile_join_cloudtag_all_repo(mut ctx, req)
}

fn find_fms_cloudfile_join_cloudtag_all_domain() {}

pub struct FmsCloudFileCloudFileTagListReq {
	page              int    @[json: 'page']
	page_size         int    @[json: 'pageSize']
	cloud_file_tag_id string @[json: 'cloudFileTagId']
	cloud_file_id     string @[json: 'cloudFileId']
}

pub struct FmsCloudFileCloudFileTagData {
	cloud_file_tag_id string @[json: 'cloudFileTagId']
	cloud_file_id     string @[json: 'cloudFileId']
}

pub struct FmsCloudFileCloudFileTagListResp {
	total int
	data  []FmsCloudFileCloudFileTagData
}

fn find_fms_cloudfile_join_cloudtag_all_repo(mut ctx Context, req FmsCloudFileCloudFileTagListReq) !FmsCloudFileCloudFileTagListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	mut count := sql db {
		select count from FmsCloudFileCloudFileTag
	} or { return error('Failed: ${err}') }
	offset_num := (req.page - 1) * req.page_size
	where_expr := {
		if req.cloud_file_tag_id != '' { cloud_file_tag_id == req.cloud_file_tag_id },
		if req.cloud_file_id != '' { cloud_file_id == req.cloud_file_id }
	}
	result := sql db {
		dynamic select from FmsCloudFileCloudFileTag where where_expr limit req.page_size offset offset_num
	} or { return error('Failed: ${err}') }
	mut datalist := []FmsCloudFileCloudFileTagData{}
	for row in result {
		datalist << FmsCloudFileCloudFileTagData{
			cloud_file_tag_id: row.cloud_file_tag_id
			cloud_file_id:     row.cloud_file_id
		}
	}
	return FmsCloudFileCloudFileTagListResp{
		total: count
		data:  datalist
	}
}
