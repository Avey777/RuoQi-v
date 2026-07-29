module tenant_member

import veb
import log
import json2 as json
import model { Context }
import model.schema_tenant { TnMember }
import common.api as capi

// ═══ Handler ═══
@['/remove_member'; post]
pub fn (app &TenantMember) remove_member_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[RemoveMemberReq](ctx.req.data) or {
		return ctx.json(capi.json_error_400(err.msg()))
	}
	result := remove_member_usecase(mut ctx, req) or {
		return ctx.json(capi.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(capi.json_success_200(result))
}

// ═══ Use Case ═══
pub fn remove_member_usecase(mut ctx Context, req RemoveMemberReq) !RemoveMemberResp {
	remove_member_domain(req)!
	return remove_member_repo(mut ctx, req)
}

// ═══ Domain ═══
fn remove_member_domain(req RemoveMemberReq) ! {
	if req.user_id == '' { return error('userId is required') }
}

// ═══ DTO ═══
pub struct RemoveMemberReq {
	user_id string @[json: 'userId']
}

pub struct RemoveMemberResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn remove_member_repo(mut ctx Context, req RemoveMemberReq) !RemoveMemberResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire scoped DB: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	tenant_id := ctx.svc_iam.active_tenant_id
	product_id := ctx.svc_iam.active_subproduct_id
	portal_id := ctx.svc_iam.active_subportal_id

	sql db {
		update TnMember set del_flag = 1, status = 1 where user_id == req.user_id
		&& tenant_id == tenant_id && product_id == product_id && portal_id == portal_id
		&& del_flag == 0
	}!
	return RemoveMemberResp{
		msg: '成员已移除'
	}
}
