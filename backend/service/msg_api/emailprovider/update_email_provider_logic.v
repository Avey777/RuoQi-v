module emailprovider

import veb
import log
import time
import json2 as json
import model.schema_msg { MsgEmailProvider }
import common.api
import model { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &EmailProvider) update_email_provider_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateEmailProviderReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_email_provider_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn update_email_provider_usecase(mut ctx Context, req UpdateEmailProviderReq) !UpdateEmailProviderResp {
	update_email_provider_domain(req)!
	return update_email_provider_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_email_provider_domain(req UpdateEmailProviderReq) ! {
	if req.id == '' {
		return error('email provider id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateEmailProviderReq {
	id         string  @[json: 'id']
	name       ?string @[json: 'name']
	auth_type  ?u8     @[json: 'authType']
	email_addr ?string @[json: 'emailAddr']
	password   ?string @[json: 'password']
	host_name  ?string @[json: 'hostName']
	identify   ?string @[json: 'identify']
	secret     ?string @[json: 'secret']
	port       ?u32    @[json: 'port']
	tls        ?u8     @[json: 'tls']
	is_default ?u8     @[json: 'isDefault']
}

pub struct UpdateEmailProviderResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_email_provider_repo(mut ctx Context, req UpdateEmailProviderReq) !UpdateEmailProviderResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	up_expr := {
		if name := req.name { name == name },
		if auth_type := req.auth_type { auth_type == auth_type },
		if email_addr := req.email_addr { email_addr == email_addr },
		if password := req.password { password == password },
		if host_name := req.host_name { host_name == host_name },
		if identify := req.identify { identify == identify },
		if secret := req.secret { secret == secret },
		if port := req.port { port == port },
		if tls := req.tls { tls == tls },
		if is_default := req.is_default { is_default == is_default },
		updated_at == time.now()
	}

	sql db {
		dynamic update MsgEmailProvider set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateEmailProviderResp{
		msg: 'EmailProvider updated successfully'
	}
}
