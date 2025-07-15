function testitrf
%TESTITRF   Test ITRF2ITRF and ITRF2ETRF with actual realizations.
%   TESTITRF runs a number of test cases for the ITRF2ITRF and ITRF2ETRF
%   Matlab functions using published ITRF and ETRF coordinates.
%   It prints the closure errors for the direct and inverse transformation
%   for a number of test cases. As coordinates from actual ITRF and ETRF 
%   realizations are used closure errors will not be zero, but should be
%   within the error margins (whatever they be) of the cooordinates.
%
%   See also ITRF2ITRF and ITRF2ETRF.
%
%  (c) Hans van der Marel, Delft University of Technology, 2012-2025.

%  Created:  24 March 2012 by Hans van der Marel
%  Modified: 28 May 2025 by Hans van der Marel
%             - combined three test functions into one

fprintf('\nKootwijk (ITRF2ITRF)\n--------------------\n\n')
evalitrf({ ...
'Kootwijk','ITRF2000', 1997.0 ,[ 3899225.2450  396731.8090 5015078.3510 -0.0134  0.0165  0.0099 ] ; ...
'Kootwijk','ITRF2000', 2000.0 ,[ 3899225.2048  396731.8585 5015078.3807 -0.0134  0.0165  0.0099 ] ; ...
'Kootwijk','ITRF2005', 2000.0 ,[ 3899225.2031  396731.8591 5015078.3845 -0.0135  0.0164  0.0113 ] ; ...
'Kootwijk','ITRF2008', 2000.0 ,[ 3899225.2015  396731.8597 5015078.3845 -0.0138  0.0164  0.0113 ] ; ...
'Kootwijk','ITRF97  ', 2000.0 ,[ 3899225.2175  396731.8646 5015078.3659 -0.0134  0.0163  0.0086 ] ; ...
'Kootwijk','ITRF96  ', 2000.0 ,[ 3899225.2175  396731.8646 5015078.3659 -0.0134  0.0163  0.0086 ] ; ...
'Kootwijk','ITRF94  ', 2000.0 ,[ 3899225.2175  396731.8646 5015078.3659 -0.0134  0.0163  0.0086 ] ; ...
'Kootwijk','ITRF93  ', 2000.0 ,[ 3899225.1554  396731.8993 5015078.3877 -0.0210  0.0203  0.0127 ] ; ...
'Kootwijk','ITRF89  ', 2000.0 ,[ 3899225.2577  396731.9023 5015078.3199 -0.0134  0.0163  0.0086 ] ; ...
'Kootwijk','ITRF89  ', 1989.0 ,[ 3899225.4051  396731.7232 5015078.2259 -0.0134  0.0163  0.0086 ] ; ...
'Kootwijk','ETRF2000', 1997.0 ,[ 3899225.4065  396731.7245 5015078.2301  0.0000 -0.0004  0.0008 ] ; ...
'Kootwijk','ETRF2000', 2000.0 ,[ 3899225.4066  396731.7231 5015078.2325  0.0000 -0.0004  0.0008 ] ...
});

%'Kootwijk','ETRF97',   1997.0 ,[ 3899225.4060  396731.7195 5015078.2187  0.0000 -0.0009 -0.0005 ] ; ...
%'Kootwijk','ETRF93',   1997.0 ,[ 3899225.3994  396731.7279 5015078.2154 -0.0008 -0.0001 -0.0014 ] ; ...
% Kootwijk  ETRF97    2000.0  3899198.6320  396765.9661 5015096.3246  0.0000 -0.0009 -0.0005

fprintf('\n\nWesterbork  (ITRF2ITRF)\n----------------------\n\n')
evalitrf({ ...
'WSRT','ITRF2020',2015.0,[ 3828735.7157  443305.1176 5064884.8162 -0.01538 0.01606 0.00954 ] ; ...
'WSRT','ITRF2014',2010.0,[ 3828735.7842  443305.0349 5064884.7562 -0.01548 0.01599 0.00948 ] ; ...
'WSRT','ITRF2008',2005.0,[ 3828735.863   443304.957  5064884.712  -0.0153  0.0160  0.0096  ] ; ...
'WSRT','ITRF2005',2000.0,[ 3828735.941   443304.878  5064884.664  -0.0145  0.0159  0.0103  ]
});

fprintf('\nKootwijk (ITRF2ETRF)\n--------------------\n\n')

evaletrf('13504M003 KOOTWIJK', ...
   'ITRF94',1993.0,[  3899225.315   396731.752  5015078.302    -.0146    .0173    .0089 ], ... 
   'ETRF94',1989.0,[  3899225.414   396731.723  5015078.218    -.0012    .0002   -.0002 ]);

evaletrf('13504M003 KOOTWIJK', ...
   'ITRF96',1997.0,[  3899225.259   396731.819  5015078.345    -.0132    .0163    .0100 ], ... 
   'ETRF96',1989.0,[  3899225.406   396731.730  5015078.216     .0002   -.0009    .0009 ]);

evaletrf('13504M003 KOOTWIJK', ...
   'ITRF97',1997.0,[  3899225.258   396731.815  5015078.341    -.0130    .0158    .0092 ], ... 
   'ETRF97',1989.0,[  3899225.404   396731.729  5015078.219     .0004   -.0013    .0002 ]);

evaletrf('13504M003 KOOTWIJK', ...
   'ITRF2000',1997.0,[  3899225.245   396731.809  5015078.351    -.0134    .0165    .0099 ], ... 
   'ETRF2000',1989.0,[  3899225.406   396731.728  5015078.224     .0000   -.0004    .0008 ]);

end


% Internal functions

function evalitrf(testdata)

ntest=size(testdata,1);
for k=1:ntest
   name=testdata{k,1};
   frame1=testdata{k,2};
   epoch1=testdata{k,3};
   crd1=testdata{k,4};
   for l=k+1:ntest
     frame2=testdata{l,2};
     epoch2=testdata{l,3};
     crd2=testdata{l,4};

     crd2test=itrf2itrf(crd1,frame1,frame2,epoch1,epoch2);
     fprintf('%8s (%.1f) -> %8s (%.1f) closure %5.2f %5.2f %5.2f mm  %5.2f %5.2f %5.2f mm/y\n',frame1,epoch1,frame2,epoch2,(crd2test-crd2)*1000);

     crd1test=itrf2itrf(crd2,frame2,frame1,epoch2,epoch1);
     fprintf('%8s (%.1f) -> %8s (%.1f) closure %5.2f %5.2f %5.2f mm  %5.2f %5.2f %5.2f mm/y\n\n',frame2,epoch2,frame1,epoch1,(crd1test-crd1)*1000);

   end
end

end

function evaletrf(name,frame1,epoch1,crd1,frame2,epoch2,crd2)

crd2test=itrf2etrf(crd1,frame1,frame2,epoch1,epoch2);
crd1test=itrf2etrf(crd2,frame2,frame1,epoch2,epoch1);

fprintf('%8s -> %8s  closure %5.2f %5.2f %5.2f mm  %5.2f %5.2f %5.2f mm/y\n',frame1,frame2,(crd2test-crd2)*1000);
fprintf('%8s -> %8s  closure %5.2f %5.2f %5.2f mm  %5.2f %5.2f %5.2f mm/y\n\n',frame2,frame1,(crd1test-crd1)*1000);

end
