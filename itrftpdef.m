function tpdef=itrftpdef()
%ITRFTPDEF  Get ITRF transformation parameters definitions.
%   TPDEF=ITRFTPDEF() returns the transformation parameters P and Pdot between 
%   the various ITRF's (http://itrf.ensg.ign.fr/). The transformation for ITRF 
%   coordinates is defined as
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
%   See also ITRFTP and ITRF2ITRF.
%
%  (c) Hans van der Marel, Delft University of Technology, 2012-2025.

%  Created:  24 March 2012 by Hans van der Marel
%  Modified: 12 March 2023 by Hans van der Marel
%            - Added ITRF2020 to ITRF2014
%            26 May 2025 by Hans van der Marel
%            - Added transformation between ITRF2000 and ETRF2014 at 2015.0
%            - Added transformation between ITRF2000 and ETRF2020 at 2015.0
%            - Checked that transformation between ITRF2000 and ETRF2000 at
%              epoch 2015.0 is the effectively the same as epoch 2000.0
%            28 May 2025 by Hans van der Marel
%            - Added node list (all valid TRF) to tpdef
%            - Added adjacency list (needed by Dijkstra's algororithm) to
%              tpdef
%            21 July 2025 by Hans van der Marel
%            - Added remaining ITRFyy-ETRFyy combinations and ITRF2005-ETRF2005

%  ITRF Transformation parameters (http://itrf.ensg.ign.fr/)
%                                                                                    .     .     .       .       .       .       .
%  FROM      TO        EPOCH      T1    T2    T3       D      R1      R2      R3     T1    T2    T3       D      R1      R2      R3
%                                 mm    mm    mm     ppb     mas     mas     mas   mm/y  mm/y  mm/y   ppb/y   mas/y   mas/y   mas/y
%  --------  --------  ------  ----- ----- -----   -----   -----   -----   -----  ----- ----- -----   -----   -----   -----   -----
CTPDEF=[  ...
  'ITRF2020  ITRF2014  2015.0   -1.4  -0.9   1.4   -0.42   0.000   0.000   0.000    0.0  -0.1   0.2    0.00   0.000   0.000   0.000'; ...
  'ITRF2014  ITRF2008  2010.0    1.6   1.9   2.4   -0.02   0.000   0.000   0.000    0.0   0.0  -0.1    0.03   0.000   0.000   0.000'; ...
  'ITRF2008  ITRF2005  2005.0   -0.5  -0.9  -4.7    0.94   0.000   0.000   0.000    0.3   0.0   0.0    0.00   0.000   0.000   0.000'; ...
  'ITRF2005  ITRF2000  2000.0    0.1  -0.8  -5.8    0.40   0.000   0.000   0.000   -0.2   0.1  -1.8    0.08   0.000   0.000   0.000'; ...
  'ITRF2000  ITRF97    1997.0    6.7   6.1 -18.5    1.55   0.000   0.000   0.000    0.0  -0.6  -1.4    0.01   0.000   0.000   0.020'; ...
  'ITRF2000  ITRF96    1997.0    6.7   6.1 -18.5    1.55   0.000   0.000   0.000    0.0  -0.6  -1.4    0.01   0.000   0.000   0.020'; ...
  'ITRF2000  ITRF94    1997.0    6.7   6.1 -18.5    1.55   0.000   0.000   0.000    0.0  -0.6  -1.4    0.01   0.000   0.000   0.020'; ...
  'ITRF2000  ITRF93    1988.0   12.7   6.5 -20.9    1.95  -0.390   0.800  -1.140   -2.9  -0.2  -0.6    0.01  -0.110  -0.190   0.070'; ...
  'ITRF2000  ITRF92    1988.0   14.7  13.5 -13.9    0.75   0.000   0.000  -0.180    0.0  -0.6  -1.4    0.01   0.000   0.000   0.020'; ...
  'ITRF2000  ITRF91    1988.0   26.7  27.5 -19.9    2.15   0.000   0.000  -0.180    0.0  -0.6  -1.4    0.01   0.000   0.000   0.020'; ...
  'ITRF2000  ITRF90    1988.0   24.7  23.5 -35.9    2.45   0.000   0.000  -0.180    0.0  -0.6  -1.4    0.01   0.000   0.000   0.020'; ...
  'ITRF2000  ITRF89    1988.0   29.7  47.5 -73.9    5.85   0.000   0.000  -0.180    0.0  -0.6  -1.4    0.01   0.000   0.000   0.020'; ...
  'ITRF2000  ITRF88    1988.0   24.7  11.5 -97.9    8.95   0.100   0.000  -0.180    0.0  -0.6  -1.4    0.01   0.000   0.000   0.020'; ...
  'ITRF89    ETRF89    1989.0    0.0   0.0   0.0    0.00   0.000   0.000   0.000    0.0   0.0   0.0    0.00   0.110   0.570  -0.710'; ...
  'ITRF90    ETRF90    1989.0   19.0  28.0 -23.0    0.00   0.000   0.000   0.000    0.0   0.0   0.0    0.00   0.110   0.570  -0.710'; ...
  'ITRF91    ETRF91    1989.0   21.0  25.0 -37.0    0.00   0.000   0.000   0.000    0.0   0.0   0.0    0.00   0.210   0.520  -0.680'; ...
  'ITRF92    ETRF92    1989.0   38.0  40.0 -37.0    0.00   0.000   0.000   0.000    0.0   0.0   0.0    0.00   0.210   0.520  -0.680'; ...
  'ITRF93    ETRF93    1989.0   19.0  53.0 -21.0    0.00   0.000   0.000   0.000    0.0   0.0   0.0    0.00   0.320   0.780  -0.670'; ...
  'ITRF94    ETRF94    1989.0   41.0  41.0 -49.0    0.00   0.000   0.000   0.000    0.0   0.0   0.0    0.00   0.200   0.500  -0.650'; ...
  'ITRF96    ETRF96    1989.0   41.0  41.0 -49.0    0.00   0.000   0.000   0.000    0.0   0.0   0.0    0.00   0.200   0.500  -0.650'; ...
  'ITRF97    ETRF97    1989.0   41.0  41.0 -49.0    0.00   0.000   0.000   0.000    0.0   0.0   0.0    0.00   0.200   0.500  -0.650'; ...
  'ITRF2000  ETRF2000  2000.0   54.0  51.0 -48.0    0.00   0.891   5.390  -8.712    0.0   0.0   0.0    0.00   0.081   0.490  -0.792'; ...
  'ITRF2005  ETRF2005  2000.0   56.0  48.0 -37.0    0.00   0.594   5.698  -8.591    0.0   0.0   0.0    0.00   0.054   0.518  -0.781'; ...
  'ITRF2014  ETRF2014  2015.0    0.0   0.0   0.0    0.00   2.210  13.806 -20.020    0.0   0.0   0.0    0.00   0.085   0.531  -0.770'; ...
  'ITRF2020  ETRF2020  2015.0    0.0   0.0   0.0    0.00   2.236  13.494 -19.578    0.0   0.0   0.0    0.00   0.086   0.519  -0.753'];
% 'ITRF2000  ETRF2000  2015.0   54.0  51.0 -48.0    0.00   2.106  12.740 -20.592    0.0   0.0   0.0    0.00   0.081   0.490  -0.792'; ...
%
% Transformation ITRF2000 to ETRF2000 at epoch 2015.0 is effectively the same as epoch 2015.0 given in the technical note.
% See also table 2, 3 and 4 of "EUREF Technical note 1: Relationhip and Transformation between the International and the 
% European Terrestial Systems".

n=size(CTPDEF,1);

tpdef.from=CTPDEF(:,1:8);
tpdef.to=CTPDEF(:,11:18);
tpdef.epoch=zeros(n,1);
tpdef.p=zeros(n,7);
tpdef.pdot=zeros(n,7);
for k=1:n
  tmp=sscanf(CTPDEF(k,20:end),'%f');
  tpdef.epoch(k)=tmp(1);
  tpdef.p(k,:)=tmp(2:8);
  tpdef.pdot(k,:)= tmp(9:15);
end

% Nodes (all valid TRF) and edges [ ifrom ito ] (incidence list)

nodes=union(tpdef.from,tpdef.to,'rows');

[~,ifrom]=ismember(tpdef.from,nodes,'rows');
[~,ito]=ismember(tpdef.to,nodes,'rows');

% Adjacency matrix (elements contain a reference to the edge, negative values
% indicate the inverse direction)

n=size(nodes,1);
m=size(ifrom,1);
A=sparse(ifrom,ito,[1:m],n,n);
A=A-A';

tpdef.nodes=nodes;
tpdef.adjacencymatrix=A;

return

