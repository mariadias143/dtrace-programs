#!/usr/sbin/dtrace -s

#pragma D option quiet

/* Exercicio 2a - Mostrar estatísticas dos processos a correr por iteração */

syscall::openat*:entry
/(arg2&O_CREAT) == 0/
{
	self->creat = 0;
    @tryOpen[execname] = count();
}

syscall::openat*:entry
/(arg2&O_CREAT) == O_CREAT/
{
	self->creat = 1;
    @tryCreat[execname] = count();
}

syscall::openat*:return
/arg1 >= 0 && self->creat == 0/
{
	@successOpen[execname] = count();
}

syscall::openat*:return
/arg1 >= 0 && self->creat == 1/
{
	@successCreat[execname] = count();
}

END
{
	printf("EXECNAME								#OPEN_TRY    #OPEN_SUCCESS      #CREAT_TRY    #CREAT_SUCCESS\n");
	printf("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ");
	printa(@tryOpen,@successOpen,@tryCreat,@successCreat);
}
