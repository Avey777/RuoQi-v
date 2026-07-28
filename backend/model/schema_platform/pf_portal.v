module schema_platform

import time

// unique_key 说明：同一产品下门户编码唯一，防止重复定义；
// 同一编码可跨产品存在（如 Mall 和 WMS 各有 seller 门户）。
@[comment: '门户定义表（seller/buyer/owner/admin 等）— 产品下有哪些门户']
@[unique_key: 'product_id,portal_code']
@[table: 'pf_portal']
pub struct PfPortal {
pub:
	id          string     @[comment: 'UUID'; primary; sql_type: 'CHAR(36)']
	product_id  string     @[comment: '所属产品ID'; sql_type: 'CHAR(36)']
	portal_code string     @[comment: '门户编码: seller/buyer/owner/admin'; sql_type: 'VARCHAR(64)']
	portal_name string     @[comment: '门户名称'; sql_type: 'VARCHAR(255)']
	description string     @[comment: '门户描述'; sql_type: 'VARCHAR(500)']
	status      u8         @[comment: '0正常 1停用'; default: 0; sql_type: 'tinyint']
	updater_id  ?string    @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at  time.Time  @[comment: '修改日期'; sql_type: 'TIMESTAMP']
	creator_id  ?string    @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at  time.Time  @[comment: '创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag    u8         @[comment: '0未删除 1已删除'; default: 0; sql_type: 'tinyint(1)']
	deleted_at  ?time.Time @[comment: '删除日期'; sql_type: 'TIMESTAMP']
}
