function itrftables(fromtrf,totrf,year)
%ITRFTABLES  Print transformation parameters between ITRF's.
%   ITRFTABLES(FROMTRF,TOTRF,YEAR) prints tables with the transformation 
%   parameters FROMTRF and TOTRF at epoch YEAR. Either FROMTRF, or TOTRF, may
%   contain a pattern, but not both at the same time. At least one has to
%   resolve to a unique TRF.
%
%   This function can be used to reproduce tables given in EUREF TN 1
%   and other tables that can be found at IERS.
%
%   See also ITRFTP and ITRFTPDEF.
%
%  (c) Hans van der Marel, Delft University of Technology, 2012-2025.

%  Created:  24 March 2012 by Hans van der Marel
%  Modified: 28 May 2025 by Hans van der Marel
%             - Added input arguments to enhance flexibility
%             - Print single table of choice

tpdef=itrftpdef;

fromtrf=upper(fromtrf);
totrf=upper(totrf);

nodes=tpdef.nodes;

fynodes=nodes;
for k=1:size(fynodes,1)
   if strcmp(fynodes(k,7:8),'  ')
      fynodes(k,7:8)=fynodes(k,5:6);
      fynodes(k,5:6)='19';
   end
end
[fynodes,idx] = sortrows(fynodes,'descend');
nodes=nodes(idx,:);

fromidx=find(contains(cellstr(nodes),fromtrf));
toidx=find(contains(cellstr(nodes),totrf));

if min(length(fromidx),length(toidx)) ~= 1
    error('At least one of TOTRF or FROMTRF must resolve to a unique TRF')
end

n=max(length(fromidx),length(toidx));
p=zeros(n,7);
pdot=zeros(n,7);

if length(toidx) == 1
   trf=nodes(fromidx,:);
   to=nodes(toidx(1),:);
   for k=1:n
      [p(k,:),pdot(k,:)]=itrftp(trf(k,:),to,year);
   end
else
   trf=nodes(toidx,:);
   from=nodes(fromidx(1),:);
   for k=1:n
      [p(k,:),pdot(k,:)]=itrftp(from,trf(k,:),year);
   end
end

fprintf('Transformation parameters at epoch %.1f from %s to %s.\n\n',year,fromtrf,totrf)

fprintf('               T1      T2      T3       D      R1      R2      R3\n')
fprintf('               mm      mm      mm     ppb     mas     mas     mas\n')
fprintf('          ------- ------- ------- ------- ------- ------- -------\n')
for k=1:n
  fprintf('%8s  %7.1f %7.1f %7.1f %7.2f %7.3f %7.3f %7.3f \n',trf(k,:),p(k,:))
end
fprintf('\n\n')

fprintf('Transformation parameter rates/year at epoch %.1f from %s to %s.\n\n',year,fromtrf,totrf)

fprintf('               .       .       .        .      .       .       .\n')
fprintf('               T1      T2      T3       D      R1      R2      R3\n')
fprintf('             mm/y    mm/y    mm/y   ppb/y   mas/y   mas/y   mas/y\n')
fprintf('          ------- ------- ------- ------- ------- ------- -------\n')
for k=1:n
  fprintf('%8s  %7.1f %7.1f %7.1f %7.2f %7.3f %7.3f %7.3f\n',trf(k,:),pdot(k,:))
end
fprintf('\n\n')

fprintf('Transformation parameters and their rates/year at epoch %.1f from %s to %s.\n\n',year,fromtrf,totrf)

fprintf('               T1      T2      T3       D      R1      R2      R3\n')
fprintf('               mm      mm      mm     ppb     mas     mas     mas\n')
fprintf('          ------- ------- ------- ------- ------- ------- -------\n')
for k=1:n
  fprintf('%8s  %7.1f %7.1f %7.1f %7.2f %7.3f %7.3f %7.3f\n',trf(k,:),p(k,:))
  fprintf('%-8s  %7.1f %7.1f %7.1f %7.2f %7.3f %7.3f %7.3f\n',' rates',pdot(k,:))
end
fprintf('\n\n')

return