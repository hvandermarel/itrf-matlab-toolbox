function [p,pdot]=itrftp(from,to,year)
%ITRFTP    Get ITRF transformation parameters at a certain epoch..
%   [P,PDOT]=ITRFTP(FROM,TO,YEAR) returns the transformation parameters P and 
%   PDOT from ITRF FROM to TO for time YEAR.  
%   The transformation for ITRF coordinates is defined as
%
%     : XS :    : X :   : T1 :   :  D   -R3   R2 : : X :
%     :    :    :   :   :    :   :               : :   :
%     : YS :  = : Y : + : T2 : + :  R3   D   -R1 : : Y :
%     :    :    :   :   :    :   :               : :   :
%     : ZS :    : Z :   : T3 :   : -R2   R1   D  : : Z :
%
%   with X,Y,Z the coordinates in the from frame and XS,YS,ZS the coordinates in 
%   the to frame. The parameters P are obtained for epoch t from
%
%     P(t) = P(EPOCH) + Pdot * (t - EPOCH)
%
%   with EPOCH is the epoch indicated in table of transformation parameters
%   and Pdot the rate of that parameter.
%
%   See also ITRFTPDEF.
%
%  (c) Hans van der Marel, Delft University of Technology.

%  Created:  24 March 2012 by Hans van der Marel
%  Modified: 

% Get all ITRF transformation parameters and save for future call's

persistent tpdef validitrf;
if isempty(tpdef) || isempty(validitrf)
  tpdef=itrftpdef();
  validitrf=union(tpdef.from,tpdef.to,'rows');
end

% Check the input arguments

verbose=0;

if nargin ~= 3
  error('ITRFTP must be called with three input arguments.')
end

from=upper(from);
to=upper(to);
if ~ismember(from,validitrf,'rows')
  error(['Invalid ITRF in FROM argument of ITRFTP (' from ').'])
end
if ~ismember(to,validitrf,'rows')
  error(['Invalid ITRF in TO argument of ITRFTP (' to ').'])
end
if strcmpi(from,to)
  %warning('ITRF in TO and FROM argument of ITRFTP must be different.')
  if verbose 
    disp([ from ' -> ' to '  <=> '])
  end
  p=zeros(1,7);
  pdot=zeros(1,7);
  return
end

if year < 100
  year=year+1900;
end

% Check the direction of the transformation

yfrom=sscanf(from(5:end),'%d');
if yfrom < 100, yfrom=yfrom+1900;, end
yto=sscanf(to(5:end),'%d');
if yto < 100, yto=yto+1900;, end
reverse=0;
if yfrom < yto || ( ismember(from,'ETRF2000','rows') && ismember(to,'ITRF2000','rows') )
  reverse=1;
  tmp=from;
  from=to;
  to=tmp;
end

% Identify the to frame (the to frames must be unique!!)

[lto,idxto]=ismember(to,tpdef.to,'rows');
if lto
  pdot=tpdef.pdot(idxto,:);
  p=tpdef.p(idxto,:) + pdot .* ( year - tpdef.epoch(idxto) );
  origin=tpdef.from(idxto,:);
  if ~ismember(from,origin,'rows')
    [p1,pdot1]=itrftp(from,origin,year);
    p=p1+p;
    pdot=pdot1+pdot;
  end
  if verbose
    disp([ origin ' -> ' to ])
  end
else
  error('This should not happen, something is terribly wrong!')
end

% end

if reverse
  p=-1.*p;
  pdot=-1.*pdot;
end

return
