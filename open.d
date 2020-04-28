BEGIN
{
	printf("%-6s %-20s %-6s %-6s %-64s %-16s %s\n","PID","PROCESS","UID","GID","FILENAME","MODE","RETURN");
}

syscall::openat:entry
{
	self->path = arg1;
    	self->flag = arg2;
}

syscall::openat:return
/"/etc" == stringof(copyin(self->path,4)) && pid != $pid && self->path != NULL /
{
	printf("%-6d %-20s %-6d %-6d %-64s %-16x %d\n", pid, execname, uid, gid, copyinstr(self->path), self->flag, arg0);
    
}
