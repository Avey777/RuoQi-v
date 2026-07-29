module task

import veb
import log
import time
import rand
import json2 as json
import model.schema_job { JobTask }
import common.api
import model { Context }

// ═══ Handler ═══
@['/create'; post]
pub fn (app &Task) create_task_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateTaskReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_task_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn create_task_usecase(mut ctx Context, req CreateTaskReq) !CreateTaskResp {
	create_task_domain(req)!
	return create_task_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_task_domain(req CreateTaskReq) ! {
	if req.name == '' {
		return error('task name is required')
	}
	if req.cron_expression == '' {
		return error('cron expression is required')
	}
	if req.pattern == '' {
		return error('task pattern is required')
	}
}

// ═══ DTO ═══
pub struct CreateTaskReq {
	name            string @[json: 'name']
	task_group      string @[json: 'taskGroup']
	cron_expression string @[json: 'cronExpression']
	pattern         string @[json: 'pattern']
	payload         string @[json: 'payload']
	status          u8     @[json: 'status']
}

pub struct CreateTaskResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_task_repo(mut ctx Context, req CreateTaskReq) !CreateTaskResp {
	time_now := time.now()
	task := JobTask{
		id:              rand.uuid_v7()
		name:            req.name
		task_group:      req.task_group
		cron_expression: req.cron_expression
		pattern:         req.pattern
		payload:         req.payload
		status:          req.status
		created_at:      time_now
		updated_at:      time_now
	}

	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert task into JobTask
	} or { return error('Failed to create Task: ${err}') }

	return CreateTaskResp{
		msg: 'Task created successfully'
	}
}
