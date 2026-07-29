module pay_api

import veb
import log
import time
import rand
import json2 as json
import model.schema_pay { PayRefund }
import common.api
import model { Context }

// ═══ Handler ═══
@['/refund/create'; post]
pub fn (app &Pay) create_pay_refund_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreatePayRefundReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_pay_refund_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn create_pay_refund_usecase(mut ctx Context, req CreatePayRefundReq) !CreatePayRefundResp {
	create_pay_refund_domain(req)!
	return create_pay_refund_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_pay_refund_domain(req CreatePayRefundReq) ! {
	if req.order_id == '' {
		return error('order id is required')
	}
	if req.reason == '' {
		return error('refund reason is required')
	}
}

// ═══ DTO ═══
pub struct CreatePayRefundReq {
	no                 string  @[json: 'no']
	channel_code       string  @[json: 'channelCode']
	order_id           string  @[json: 'orderId']
	order_no           string  @[json: 'orderNo']
	merchant_order_id  string  @[json: 'merchantOrderId']
	merchant_refund_id string  @[json: 'merchantRefundId']
	pay_price          int     @[json: 'payPrice']
	refund_price       int     @[json: 'refundPrice']
	reason             string  @[json: 'reason']
	user_ip            ?string @[json: 'userIp']
	channel_order_no   string  @[json: 'channelOrderNo']
}

pub struct CreatePayRefundResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_pay_refund_repo(mut ctx Context, req CreatePayRefundReq) !CreatePayRefundResp {
	time_now := time.now()
	refund := PayRefund{
		id:                 rand.uuid_v7()
		no:                 req.no
		channel_code:       req.channel_code
		order_id:           req.order_id
		order_no:           req.order_no
		merchant_order_id:  req.merchant_order_id
		merchant_refund_id: req.merchant_refund_id
		pay_price:          req.pay_price
		refund_price:       req.refund_price
		reason:             req.reason
		user_ip:            req.user_ip
		channel_order_no:   req.channel_order_no
		status:             1
		creator_id:         ctx.svc_iam.user_id
		updater_id:         ctx.svc_iam.user_id
		created_at:         time_now
		updated_at:         time_now
	}

	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert refund into PayRefund
	} or { return error('Failed to create PayRefund: ${err}') }

	return CreatePayRefundResp{
		msg: 'PayRefund created successfully'
	}
}
