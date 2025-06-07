function [sp,spedge]=dijkstra(A,s,d)
%DIJKSTRA  Find shortest path in a graph using Dijkstra's algorithm.
%  [SP,SPEDGE]=DIJKSTRA(A,S,D) finds shortest path SP from source S to 
%  destination D using Dijkstra's algorithm. A is the sparse adjacency matrix
%  with on the off-diagonal elements a non-zero number for each edge. SP is the 
%  shortest path from the source S to destination D, with SPEDGE for each edge
%  the corresponding value A. The distance is the length of SPEDGE, or the
%  length of SP minus one.
%
%  (c) Hans van der Marel, Delft University of Technology.

%  Created:  24 March 2012 by Hans van der Marel
%  Modified: 

% Check the input arguments

n=size(A,1);
if n ~= size(A,2) 
  error('The adjacency matrix A must be square');
end
if ~issparse(A)
  A=sparse(A);
end
if  s < 1 || s > n || d < 1 || d > n
   error('source or destination not within range of adjacency matrix');
end

% Initializations of distance function and previous node in the path

dist(1:n)=Inf;
previous(1:n)=NaN;
dist(s) = 0;

% Main loop 

% The following algorithm searches for the vertex u in the vertex set Q that 
% has the least dist[u] value. That vertex is removed from the set Q and 
% returned to the user. It then calculates the length between the two neighbor-
% nodes u and v and if this path is shorter than the current shortest path 
% recorded for v in dist[v], that current path is replaced with the shorter
% length. The previous array is populated with a pointer to the "next-hop" node 
% on the source graph to get the shortest route to the source.

Q=1:n;
while ~isempty(Q)
  % Find vertex in Q with smallest distance in dist[]
  [distu idxu]=min(dist(Q));
  u=Q(idxu);
  % Break if all remaining vertices are inaccessible from source  
  if isinf(distu)
    break;
  end
  % Break if target has been reached, if not, remove u from Q and continue
  if u == d
    break;
  else
    Q(idxu)=[];
  end
  % Find neighbors v of u, where v has not yet been removed from Q
  idxv=find(A(Q,u));
  v=Q(idxv);
  % Relax neighbours for who the distance is shorter
  relax=find( dist(v) > distu + 1);
  dist(v(relax))=distu + 1; 
  previous(v(relax))=u;
end
% niter=n-length(Q)

% Compute the shortest path

sp = [d];
spedge = [];
while sp(1) ~= s
  if isnan(previous(sp(1)))
    error('There is no path to the destination from the source');
  end
  sp=[previous(sp(1)) sp];
  spedge=[ full(A(sp(1),sp(2))) spedge];
end;
% spdist=dist(d);

return

