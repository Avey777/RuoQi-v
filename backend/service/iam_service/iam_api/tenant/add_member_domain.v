module tenant

import log
import model { Context }
import model.schema_tenant { TnSubPortal }
import model.schema_platform { PfPortal }

// validate_tn_member_subportal_exists — 插入 TnMember 的前置校验：
// 1. 确认 portal_type == 1 (tn_member)，非 ws_member 或 platform 门户
// 2. 确认 tenant_id + product_id + portal_id 已通过 TnSubPortal 入驻，
//    防止用户加入一个租户尚未订阅的门户。
// 返回 true 表示校验通过。
pub fn validate_tn_member_subportal_exists(mut ctx Context, tenant_id string, product_id string, portal_id string) !bool {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// 1. 校验门户类型必须为 tn_member (portal_type == 1)
	portal := sql db {
		select from PfPortal where id == portal_id && del_flag == 0 limit 1
	} or { return error('Failed to query PfPortal: ${err}') }
	if portal.len == 0 {
		return error('portal not found')
	}
	if portal[0].portal_type != 1 {
		return error('portal is not a tn_member type portal (portal_type must be 1)')
	}

	// 2. 校验租户已订阅该门户（TnSubPortal 存在且已激活）
	existing := sql db {
		select from TnSubPortal where tenant_id == tenant_id && product_id == product_id
		&& portal_id == portal_id && status == 1 && del_flag == 0 limit 1
	} or { return error('Failed to query TnSubPortal: ${err}') }
	if existing.len == 0 {
		return error('tenant has not subscribed to this portal (TnSubPortal not found or not active)')
	}
	return true
}
