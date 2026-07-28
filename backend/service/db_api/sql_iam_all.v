module db_api

pub const iam_user = r"
REPLACE INTO `iam_user` (`id`, `username`, `password`, `nickname`, `description`, `home_path`, `mobile`, `email`, `avatar`, `status`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`) VALUES
  ('00000000-0000-0000-0000-000000000001', 'admin', '$2a$10$3VG4yDmIBpMmNesQAtVXAenUMAif4BDvR/gHcqPv5vZAw7TmPHCZq', 'administrator', '所有者', '/dashboard', NULL, NULL, '/avatar', 0, NULL, '2025-07-25 11:11:34', NULL, '2025-07-25 11:11:34', 0, NULL);
"
