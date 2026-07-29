module pay_api

import veb
import log
import json2 as json
import model.schema_pay { PayDemoOrder }
import common.api
import model { Context }

// ═══ Handler ═══
@['/demo/by_id'; post]
pub fn (app &Pay) find_pay_demo_order_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[PayDemoOrderByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := find_pay_demo_order_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_pay_demo_order_by_id_usecase(mut ctx Context, req PayDemoOrderByIdReq) !PayDemoOrder {
	find_pay_demo_order_by_id_domain(req)!
	return find_pay_demo_order_by_id_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_pay_demo_order_by_id_domain(req PayDemoOrderByIdReq) ! {
	if req.id == '' {
		return error('demo order id is required')
	}
}

// ═══ DTO ═══
pub struct PayDemoOrderByIdReq {
	id string @[json: 'id']
}

// ═══ Repository ═══
fn find_pay_demo_order_by_id_repo(mut ctx Context, req PayDemoOrderByIdReq) !PayDemoOrder {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	orders := sql db {
		select from PayDemoOrder where id == req.id limit 1
	} or { return error('Failed: ${err}') }

	if orders.len == 0 {
		return error('PayDemoOrder not found')
	}

	return orders[0]
}
