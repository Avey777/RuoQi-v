module db_api

pub const tn_tenant = r"
REPLACE INTO `tn_tenant` (`id`, `owner_id`, `logo_url`, `name`, `type`, `slug`, `status`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '/logo', '我的团队', 1, 'my-team', 1, NULL, '2027-01-01 00:00:00', NULL, '2027-01-01 00:00:00', 0, NULL);
"

pub const tn_subportal = r"
REPLACE INTO `tn_subportal` (`id`, `tenant_id`, `product_id`, `portal_id`, `workspace_id`, `status`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 1, NULL, '2027-01-01 00:00:00', NULL, '2027-01-01 00:00:00', 0, NULL);
"

pub const tn_member = r"
REPLACE INTO `tn_member` (`tenant_id`, `user_id`, `product_id`, `portal_id`, `status`, `joined_at`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
  ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003', 0, '2027-01-01 00:00:00', NULL, '2027-01-01 00:00:00', NULL, '2027-01-01 00:00:00', 0, NULL);
"
