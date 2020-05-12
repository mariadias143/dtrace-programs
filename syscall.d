BEGIN
{
  start = timestamp;
  n_erros = 0;
  sys_calls = 0;
}

syscall:::entry
/pid == $target/
{
  @count[probefunc] = count();
  self->ts = timestamp;
  sys_calls += 1;
}

syscall:::return
/pid == $target && self->ts != 0 && errno == 0/
{
  @time[probefunc] = sum((timestamp - self->ts) / 1000000);
  self->ts = 0;
}

syscall:::return
/pid == $target && self->ts != 0 && errno > 0/
{
  @error[probefunc] = count();
  @time[probefunc] = sum((timestamp - self->ts) / 1000000);
  self->ts = 0;
  n_erros += 1;
}

END
{
  printf("syscall               milliseconds   calls  errors\n");
  printa("%-20s %12@d  %6@d %8@d\n",@time,@count,@error);
  printf("                      ------------   -----  ------\n");
  printf("sys totals:                  %d      %d      %d\n",(timestamp-start) / 1000000,sys_calls,n_erros);
}
