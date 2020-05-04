#!/usr/sbin/dtrace -s

#pragma D option quiet

/* Exercicio 2b - Mostrar estatísticas dos processos a correr a cada N segundos */

syscall::openat*:entry
/(arg2&O_CREAT) == 0/
{
	self->creat = 0;
	self->flag = arg2;
    @tryOpen[pid,execname] = count();
}

syscall::openat*:entry
/(arg2&O_CREAT) == O_CREAT/
{
	self->creat = 1;
	self->flag = arg2;
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
    printf("*******************************************************************************\n");
    printf("%-20Y\n\n", walltimestamp);
    printf("Tentativas de abrir ficheiros:\n");
	printa(@tryOpen);
	printf("\nTentativas bem sucedidas:\n");
	printa(@successOpen);
	printf("\nTentativas de criar ficheiros:\n");
	printa(@tryCreat);
	printf("\nTentativas bem sucedidas:\n");
	printa(@successCreat);
    printf("*******************************************************************************\n");
    clear(@tryOpen);
    clear(@successOpen);
    clear(@tryCreat);
    clear(@successCreat);
}
