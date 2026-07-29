module schema_workspace

@[comment: '工作区角色菜单关联表']
@[unique_key: 'workspace_id,role_id,menu_id']
@[table: 'ws_role_menu']
pub struct WsRoleMenu {
pub:
	workspace_id string @[comment: '工作区ID'; sql_type: 'CHAR(36)']
	role_id      string @[comment: '工作区角色ID→ws_role.id'; sql_type: 'CHAR(36)']
	menu_id      string @[comment: '菜单ID'; sql_type: 'CHAR(36)']
}
