#!/usr/sbin/dtrace -s

#pragma D option quiet

/* Exercicio 1 - Monitorizar chamadas ao sistema open() */

BEGIN
{
	printf("%-6s %-16s %-6s %-6s %-64s %-20s %s\n","PID","PROCESS","UID","GID","FILENAME","MODE","RETURN");
}

syscall::openat*:entry
{
	self->path = arg1;
    self->flag = arg2;
}

syscall::openat*:return
{
	printf("%-6d %-16s %-6d %-6d %-64s %-8s", pid, execname, uid, gid, copyinstr(self->path), (self->flag&O_WRONLY) ? "O_WRONLY" : (self->flag&O_RDWR) ? "O_RDWR" : "O_RDONLY");
	printf("%-8s", self->flag&O_CREAT ? " | O_CREAT" : "");
	printf("%-8s", self->flag&O_APPEND ? " | O_APPEND" : "");
	printf("%d\n",arg1);
    
}
