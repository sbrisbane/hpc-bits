-[[
--Example job_submit.lua file for Slurm
--For more information check:
-- https://slurm.schedmd.com/job_submit_plugins.html
--For the list of available fields check:
-- src/plugins/job_submit/lua/job_submit_lua.c
--]]

-- Expected location /etc/slurm/job_submit.lua

log_prefix = 'slurm_job_submit'

function _find_in_str(str, arg)
	if str ~= nil then
		return string.find(str,arg)
	else
		return false
	end
end

function _log_user_and_debug(fmt, ...)
	--[[
	    Different messages logged to end user should be associated
	    unique return code, to make those properly displayed in case
	    of modification of array job.
  	--]]

	--[[ Implicit definition of arg was removed in Lua 5.2 --]]
	local arg = {...}

	--[[
	--  Returning a message to user from slurm_job_modify is supported
	--  since Slurm 23.02, using it in older versions will result in
	--  an error message in slurmctld logs.
	--  In older versions of Lua - prior to Lua 5.2 you may need to use
	--  unpack as a built-in instead of table.unpack
	]]--

	slurm.log_user(fmt, table.unpack(arg))
	slurm.log_debug(fmt, table.unpack(arg))
end



function slurm_job_submit(job_desc, part_list, submit_uid)


	--[[ Don't block/modify any update from root --]]
	if modify_uid == 0 then
		return slurm.SUCCESS
	end

        local cmd = "grep -q ^" .. job_desc.user_name .. "$ /tmp/allusers.txt;echo $?"
        local result = io.popen( cmd )
        local output = result:read('*a')
        result:close()

        if ( tonumber(output) ~= 0) then 
           sacctcmd = "sacctmgr  -i add user " .. job_desc.user_name .. " account=root"
           local handle = io.popen(sacctcmd)
           handle:close()
           f = io.open("/tmp/allusers.txt","a")
           -- write the contents
           f:write(job_desc.user_name .. '\n')
            -- close the file handle
           f:close()
        end
	return slurm.SUCCESS
end

function  slurm_job_modify(job_desc, job_ptr, part_list, modify_uid)
	--[[
        --   While working on that it's important to understand that
        --   modification of a job array metarecord may differs from specific
        --   element modification. When job is not yet split to tasks it will
        --   be treated as one element.
        --]]


	--[[ Don't block/modify any update from root --]]
	if modify_uid == 0 then
		return slurm.SUCCESS
	end

end

