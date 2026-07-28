module schema_workspace

// unique_key 说明：同一 workspace 下同一用户对同一角色只能有一条记录；
// 用户可持有多个角色（多行），防止同一角色重复分配。
@[comment: '工作区成员角色关联表']
@[unique_key: 'workspace_id,user_id,role_id']
@[table: 'ws_member_role']
pub struct WsMemberRole {
pub:
	workspace_id string @[comment: '工作区ID'; sql_type: 'CHAR(36)']
	user_id      string @[comment: '用户ID'; sql_type: 'CHAR(36)']
	role_id      string @[comment: '工作区角色ID→ws_role.id'; sql_type: 'CHAR(36)']
}
