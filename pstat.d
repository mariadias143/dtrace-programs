#!/usr/sbin/dtrace -s

#pragma D option quiet

/* Exercicio 2a - Mostrar estatísticas dos processos a correr por iteração */

syscall::openat*:entry
/(arg2&O_CREAT) == 0/
{
	self->creat = 0;
	self->flag = arg2;
    	@tryOpen[pid,execname,copyinstr(arg1),arg2] = count();
}

syscall::openat*:entry
/(arg2&O_CREAT) == O_CREAT/
{
	self->creat = 1;
	self->flag = arg2;
    	@tryCreat[pid,execname,copyinstr(arg1),arg2] = count();
}

syscall::openat*:return
/(int)arg1 >= 0 && self->creat == 0/
{
	@successOpen[pid,execname] = count();
}

syscall::openat*:return
/(int)arg1 >= 0 && self->creat == 1/
{
	@successCreat[pid,execname] = count();
}

END
{
	printf("Tentativas de abrir ficheiros: (pid - processo - file - modo - count)\n");
	printa(@tryOpen);
	printf("\nTentativas bem sucedidas: (pid - processo - count)\n");
	printa(@successOpen);
	printf("\nTentativas de criar ficheiros (pid - processo - file - modo - count):\n");
	printa(@tryCreat);
	printf("\nTentativas bem sucedidas (pid - processo - count):\n");
	printa(@successCreat);
}
