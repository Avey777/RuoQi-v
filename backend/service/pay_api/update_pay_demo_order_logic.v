module pay_api

import veb
import log
import time
import json2 as json
import model.schema_pay { PayDemoOrder }
import common.api
import model { Context }

// ═══ Handler ═══
@['/demo/update'; post]
pub fn (app &Pay) update_pay_demo_order_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdatePayDemoOrderReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_pay_demo_order_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn update_pay_demo_order_usecase(mut ctx Context, req UpdatePayDemoOrderReq) !UpdatePayDemoOrderResp {
	update_pay_demo_order_domain(req)!
	return update_pay_demo_order_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_pay_demo_order_domain(req UpdatePayDemoOrderReq) ! {
	if req.id == '' {
		return error('demo order id is required')
	}
}

// ═══ DTO ═══
pub struct UpdatePayDemoOrderReq {
	id               string     @[json: 'id']
	spu_name         ?string    @[json: 'spuName']
	pay_status       ?u8        @[json: 'payStatus']
	pay_order_id     ?string    @[json: 'payOrderId']
	pay_time         ?time.Time @[json: 'payTime']
	pay_channel_code ?string    @[json: 'payChannelCode']
	pay_refund_id    ?string    @[json: 'payRefundId']
	refund_price     ?int       @[json: 'refundPrice']
	refund_time      ?time.Time @[json: 'refundTime']
}

pub struct UpdatePayDemoOrderResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_pay_demo_order_repo(mut ctx Context, req UpdatePayDemoOrderReq) !UpdatePayDemoOrderResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	up_expr := {
		if spu_name := req.spu_name { spu_name == spu_name },
		if pay_status := req.pay_status { pay_status == pay_status },
		if pay_order_id := req.pay_order_id { pay_order_id == pay_order_id },
		if pay_time := req.pay_time { pay_time == pay_time },
		if pay_channel_code := req.pay_channel_code { pay_channel_code == pay_channel_code },
		if pay_refund_id := req.pay_refund_id { pay_refund_id == pay_refund_id },
		if refund_price := req.refund_price { refund_price == refund_price },
		if refund_time := req.refund_time { refund_time == refund_time },
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}

	sql db {
		dynamic update PayDemoOrder set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdatePayDemoOrderResp{
		msg: 'PayDemoOrder updated successfully'
	}
}
