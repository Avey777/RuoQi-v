module schema_workspace

@[comment: '工作区角色API关联表']
@[unique_key: 'workspace_id,role_id,api_id']
@[table: 'ws_role_api']
pub struct WsRoleApi {
pub:
	workspace_id string @[comment: '工作区ID'; sql_type: 'CHAR(36)']
	role_id      string @[comment: '工作区角色ID→ws_role.id'; sql_type: 'CHAR(36)']
	api_id       string @[comment: 'API ID'; sql_type: 'CHAR(36)']
}
