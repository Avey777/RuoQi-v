module db_api

pub const ws_workspace = r"
REPLACE INTO `ws_workspace` (`id`, `tenant_id`, `name`, `description`, `status`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '默认工作区', '系统默认工作区', 0, NULL, '2025-11-04 10:28:45', NULL, '2025-11-04 10:28:48', 0, NULL);
"

pub const ws_role = r"
REPLACE INTO `ws_role` (`id`, `workspace_id`, `name`, `code`, `description`, `sort`, `status`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '空间管理员', 'workspace_admin', '默认工作区管理员角色', 1, 0, NULL, '2025-07-25 11:16:05', NULL, '2025-07-25 11:16:00', 0, NULL);
"

pub const ws_member = r"
REPLACE INTO `ws_member` (`workspace_id`, `user_id`, `joined_at`, `status`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '2025-07-25 11:16:00', 0, NULL, '2025-07-25 11:16:00', NULL, '2025-07-25 11:16:00', 0, NULL);
"

pub const ws_member_role = r"
REPLACE INTO `ws_member_role` (`workspace_id`, `user_id`, `role_id`) VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001');
"

pub const ws_department = r"
REPLACE INTO `ws_department` (`id`, `workspace_id`, `parent_id`, `name`, `code`, `description`, `sort`, `status`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '0', '默认部门', 'default', '系统默认部门', 1, 0, NULL, '2025-08-25 20:58:59', NULL, '2025-08-21 09:53:34', 0, NULL);
"

pub const ws_position = r"
REPLACE INTO `ws_position` (`id`, `workspace_id`, `name`, `code`, `description`, `sort`, `status`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '默认岗位', 'default', '系统默认岗位', 1, 0, NULL, '2025-09-25 09:56:32', NULL, '2025-09-25 09:56:38', 0, NULL);
"
