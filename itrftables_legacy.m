function itrftables
%ITRFTABLES  Print transformation parameters between ITRF's.
%   ITRFTABLES prints the transformation parameters between ITRF's.
%
%   See also ITRFTP and ITRFTPDEF.
%
%  (c) Hans van der Marel, Delft University of Technology, 2012.

%  Created:  24 March 2012 by Hans van der Marel
%  Modified: 

yys = [   89   90   91   92   93   94   96   97 2000 2005 2008 2014];
t0s = [ 1988 1988 1988 1988 1988 1988 1988 1988 1997 2000 2005 2010];

n=length(yys);
p=zeros(n,7);
pdot=zeros(n,7);
to=sprintf('ITRF%d',yys(1));
for k=2:n
  from=sprintf('ITRF%d',yys(k));
  year=t0s(k);
  [p(k,:),pdot(k,:)]=itrftp(from,to,year);
end

fprintf('Table 1 - Transformation parameters from ITRFyy to ITRF89\n\n')

fprintf('               T1      T2      T3       D      R1      R2      R3     epoch\n')
fprintf('               mm      mm      mm     ppb     mas     mas     mas\n')
fprintf('          ------- ------- ------- ------- ------- ------- -------    ------\n')
for k=2:n
  from=sprintf('ITRF%d',yys(k));
  year=t0s(k);
  fprintf('%8s  %7.1f %7.1f %7.1f %7.3f %7.2f %7.2f %7.2f   %7.1f\n',from,p(k,:),year)
end
fprintf('\n\n')

fprintf('Table 2 - Rates of change of the transformation parameters from ITRFyy to ITRF89\n\n')

fprintf('               .       .       .        .      .       .       .\n')
fprintf('               T1      T2      T3       D      R1      R2      R3\n')
fprintf('             mm/y    mm/y    mm/y   ppb/y   mas/y   mas/y   mas/y\n')
fprintf('          ------- ------- ------- ------- ------- ------- -------\n')
for k=2:n
  from=sprintf('ITRF%d',yys(k));
  fprintf('%8s  %7.1f %7.1f %7.1f %7.3f %7.2f %7.2f %7.2f\n',from,pdot(k,:))
end
fprintf('\n\n')

to='ETRF2000';
year=2000;
for k=1:n
  from=sprintf('ITRF%d',yys(k));
  [p(k,:),pdot(k,:)]=itrftp(from,to,year);
end

fprintf('Table 5 - Transformation parameters from ITRFyy to ETRF2000 at epoch 2000.0\n\n')

fprintf('               T1      T2      T3       D      R1      R2      R3\n')
fprintf('               mm      mm      mm     ppb     mas     mas     mas\n')
fprintf('          ------- ------- ------- ------- ------- ------- -------\n')
for k=n:-1:1
  from=sprintf('ITRF%d',yys(k));
  fprintf('%8s  %7.1f %7.1f %7.1f %7.2f %7.3f %7.3f %7.3f\n',from,p(k,:))
  fprintf('%8s  %7.1f %7.1f %7.1f %7.2f %7.3f %7.3f %7.3f\n','rates',pdot(k,:))
end
fprintf('\n\n')

return