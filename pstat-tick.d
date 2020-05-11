#!/usr/sbin/dtrace -s

#pragma D option quiet

/* Exercicio 2b - Mostrar estatísticas dos processos a correr a cada N segundos */

syscall::openat*:entry
/(arg2&O_CREAT) == 0/
{
	self->creat = 0;
    @tryOpen[pid,execname] = count();
}

syscall::openat*:entry
/(arg2&O_CREAT) == O_CREAT/
{
	self->creat = 1;
    @tryCreat[pid,execname] = count();
}

syscall::openat*:return
/arg1 >= 0 && self->creat == 0/
{
	@successOpen[pid,execname] = count();
}

syscall::openat*:return
/arg1 >= 0 && self->creat == 1/
{
	@successCreat[pid,execname] = count();
}

tick-$1sec
{
    printf("%-20Y\n", walltimestamp);
    printf("PID        EXECNAME							#OPEN_TRY    #OPEN_SUCCESS      #CREAT_TRY    #CREAT_SUCCESS\n");
	printf("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ");
	printa(@tryOpen,@successOpen,@tryCreat,@successCreat);
	printf("\n\n");
    clear(@tryOpen);
    clear(@successOpen);
    clear(@tryCreat);
    clear(@successCreat);
}
