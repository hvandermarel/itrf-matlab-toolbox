function [p,pdot]=itrftp(from,to,year,verbose)
%ITRFTP    Get ITRF transformation parameters at a certain epoch..
%   [P,PDOT]=ITRFTP(FROM,TO,YEAR) returns the transformation parameters P and 
%   PDOT at epoch YEAR between TRF (ITRFyy, ITRFyyyy, ETRFyyyy) FROM and TO.  
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
%  Modified: 28 May 2025 by Hans van der Marel
%             - New version using Dijkstra's algorith to find the shortest
%               path, and tpdef containing nodes and adjacency matrix

% Get all ITRF transformation parameters and save for future call's

persistent tpdef;
if isempty(tpdef)
  tpdef=itrftpdef();
end

% Check the input arguments

if nargin < 3
  error('ITRFTP must be called with al least three input arguments.')
end

from=upper(from);
to=upper(to);

if year < 100
  year=year+1900;
end

if nargin <= 3
   verbose=0;
end

% Check if source and destination TRF are valid and get the node number

[i,s]=ismember(from,tpdef.nodes,'rows');
if i==0
  error(['Invalid TRF in FROM argument of ITRFTP (' from ').'])
end
[i,d]=ismember(to,tpdef.nodes,'rows');
if i==0
  error(['Invalid TRF in TO argument of ITRFTP (' to ').'])
end


% Return null transformation in case input and output TRF are the same

if s == d
  if verbose 
     fprintf('%s -> %s:   (null transform)',tpdef.nodes(s,:),tpdef.nodes(d,:));
  end
  p=zeros(1,7);
  pdot=zeros(1,7);
  return
end

% Use Dijkstra's algorithm to find the shortest path

[sp,spedge]=dijkstra(tpdef.adjacencymatrix,s,d);

if verbose
   fprintf('%s -> %s :   %s',tpdef.nodes(s,:),tpdef.nodes(d,:),tpdef.nodes(sp(1),:));
   for i=2:length(sp)
       fprintf(' -> %s',tpdef.nodes(sp(i),:));
   end
   fprintf('\n')
end

% Compute the transformation parameters

p=zeros(1,7);
pdot=zeros(1,7);
for i=1:length(spedge)
  ii=spedge(i);
  if ii > 0
     if verbose, disp(['   ' tpdef.from(ii,:) ' -> ' tpdef.to(ii,:) ]); end
     pdot = pdot + tpdef.pdot(ii,:);
     p = p + tpdef.p(ii,:) + tpdef.pdot(ii,:) .* ( year - tpdef.epoch(ii) );
  else
     if verbose, disp(['   ' tpdef.to(-ii,:) ' -> ' tpdef.from(-ii,:)  '  (inverse)']); end
     pdot = pdot - tpdef.pdot(-ii,:);
     p = p - tpdef.p(-ii,:) - tpdef.pdot(-ii,:) .* ( year - tpdef.epoch(-ii) );
  end
end

return

