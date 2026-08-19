# RuoQi-v 项目命令

# ─── 开发 ───────────────────────────────────────────
dev:
    cd backend && v -d trace_orm -d veb_livereload watch run ./main -f etc/config_dev.toml

test:
    cd backend && v -d trace_orm  run ./main -f etc/config_dev.toml

uat:
    cd backend && v -d trace_orm  run ./main -f etc/config.toml

build:
    cd backend && v -o app ./main

build_prod:
    cd backend && v -prod -o app ./main

# ─── OpenAPI ────────────────────────────────────────
openapi:
    cd backend && v run openapi/openapi_generate.vsh

# ─── 前端 ──────────────────────────────────────────
frontend_get:
    cd frontend && flutter pub get

frontend_analyze:
    cd frontend && melos analyze

frontend_test:
    cd frontend && melos test

frontend_gen:
    cd frontend && melos gen

# ─── 工具 ──────────────────────────────────────────
kill:
    lsof -ti :9009 | xargs -r sudo kill -9
