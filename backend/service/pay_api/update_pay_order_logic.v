module pay_api

import veb
import log
import time
import json2 as json
import model.schema_pay { PayOrder }
import common.api
import model { Context }

// ═══ Handler ═══
@['/order/update'; post]
pub fn (app &Pay) update_pay_order_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdatePayOrderReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_pay_order_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn update_pay_order_usecase(mut ctx Context, req UpdatePayOrderReq) !UpdatePayOrderResp {
	update_pay_order_domain(req)!
	return update_pay_order_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_pay_order_domain(req UpdatePayOrderReq) ! {
	if req.id == '' {
		return error('pay order id is required')
	}
}

// ═══ DTO ═══
pub struct UpdatePayOrderReq {
	id                string     @[json: 'id']
	channel_code      ?string    @[json: 'channelCode']
	merchant_order_id ?string    @[json: 'merchantOrderId']
	subject           ?string    @[json: 'subject']
	body              ?string    @[json: 'body']
	price             ?int       @[json: 'price']
	channel_fee_rate  ?f64       @[json: 'channelFeeRate']
	channel_fee_price ?int       @[json: 'channelFeePrice']
	user_ip           ?string    @[json: 'userIp']
	refund_price      ?int       @[json: 'refundPrice']
	channel_user_id   ?string    @[json: 'channelUserId']
	channel_order_no  ?string    @[json: 'channelOrderNo']
	success_time      ?time.Time @[json: 'successTime']
	notify_time       ?time.Time @[json: 'notifyTime']
	status            ?u8        @[json: 'status']
}

pub struct UpdatePayOrderResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_pay_order_repo(mut ctx Context, req UpdatePayOrderReq) !UpdatePayOrderResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	up_expr := {
		if channel_code := req.channel_code { channel_code == channel_code },
		if merchant_order_id := req.merchant_order_id { merchant_order_id == merchant_order_id },
		if subject := req.subject { subject == subject },
		if body := req.body { body == body },
		if price := req.price { price == price },
		if channel_fee_rate := req.channel_fee_rate { channel_fee_rate == channel_fee_rate },
		if channel_fee_price := req.channel_fee_price { channel_fee_price == channel_fee_price },
		if user_ip := req.user_ip { user_ip == user_ip },
		if refund_price := req.refund_price { refund_price == refund_price },
		if channel_user_id := req.channel_user_id { channel_user_id == channel_user_id },
		if channel_order_no := req.channel_order_no { channel_order_no == channel_order_no },
		if success_time := req.success_time { success_time == success_time },
		if notify_time := req.notify_time { notify_time == notify_time },
		if status := req.status { status == status },
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}

	sql db {
		dynamic update PayOrder set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdatePayOrderResp{
		msg: 'PayOrder updated successfully'
	}
}
