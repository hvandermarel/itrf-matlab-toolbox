function tpdef=etrftpdef()
%ETRFTPDEF  Get ETRF transformation parameters definitions.
%   TPDEF=ETRFTPDEF() returns the transformation parameters P from ITRFyy
%   to ETRFyy. The transformation is defined as
%                                         .    .
%     : XE :    : XI :   : T1 :   :  0   -R3   R2 : : XI :
%     :    :    :    :   :    :   :  .         .  : :    :
%     : YE :  = : YI : + : T2 : + :  R3   0   -R1 : : YI : * (t - 1989.0)
%     :    :    :    :   :    :   :  .    .       : :    :
%     : ZE :    : ZI :   : T3 :   : -R2   R1   0  : : ZI :
%
%   with XI,YI,ZI the coordinates in ITRFyy and XE,YE,ZE the coordinates in 
%   ETRFyy. 
%
%   See also ITRF2ETRF.
%
%  (c) Hans van der Marel, Delft University of Technology.

%  Created:  24 March 2012 by Hans van der Marel
%  Modified: 26 May 2025 by Hans van der Marel
%            - added ERTF2014 and ETRF2020
%            - updated reference to EUREF Technical note 1

%  Transformation parameters ITRFyy to ETRFyy at epoch 1989.0

% Transformation parameters from table 1 f "EUREF Technical note 1: Relationhip and 
% Transformation between the International and the European Terrestial Systems".

%                                   .      .      .
%   FRAME       T1    T2    T3      R1     R2     R3
%               mm    mm    mm   mas/y  mas/y  mas/y
%  --------  ----- ----- -----   -----  -----  -----
CTPDEF=[  ...
  'ETRF89      0.0   0.0   0.0   0.110  0.570 -0.710'; ...
  'ETRF90     19.0  28.0 -23.0   0.110  0.570 -0.710'; ...
  'ETRF91     21.0  25.0 -37.0   0.210  0.520 -0.680'; ...
  'ETRF92     38.0  40.0 -37.0   0.210  0.520 -0.680'; ...
  'ETRF93     19.0  53.0 -21.0   0.320  0.780 -0.670'; ...
  'ETRF94     41.0  41.0 -49.0   0.200  0.500 -0.650'; ...
  'ETRF96     41.0  41.0 -49.0   0.200  0.500 -0.650'; ...
  'ETRF97     41.0  41.0 -49.0   0.200  0.500 -0.650'; ...
  'ETRF2000   54.0  51.0 -48.0   0.081  0.490 -0.792'; ...
  'ETRF2005   56.0  48.0 -37.0   0.054  0.518 -0.781'; ...
  'ETRF2014    0.0   0.0   0.0   0.085  0.531 -0.770'; ...
  'ETRF2020    0.0   0.0   0.0   0.086  0.519 -0.753'];

n=size(CTPDEF,1);

tpdef.to=CTPDEF(:,1:8);
tpdef.p=zeros(n,6);
for k=1:n
  tpdef.p(k,:)=sscanf(CTPDEF(k,10:end),'%f');
end

return
