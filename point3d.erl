-module(point3d).
-compile(export_all).
-record(point3d,{x=0,y=0,z=0}).

new(X,Y,Z) -> #point3d{x=X,y=Y,z=Z}.

% Usage: point3d:x(MyPoint).
% (alt: MyPoint#point3d.x)
%
x(#point3d{x=X}) -> X.

length(#point3d{x=X,y=Y,z=Z}) -> math:sqrt((X*X) + (Y*Y) + (Z*Z)).

r(#point3d{}=P3d) -> point3d:length(P3d).

% Usage: point3d:plus(P1,P2).
% 
plus(#point3d{x=X,y=Y,z=Z},#point3d{x=X2,y=Y2,z=Z2}) -> #point3d{x=X+X2,y=Y+Y2,z=Z+Z2}.

minus(#point3d{x=X,y=Y,z=Z},#point3d{x=X2,y=Y2,z=Z2}) -> #point3d{x=X-X2,y=Y-Y2,z=Z-Z2}.

times(#point3d{x=X,y=Y,z=Z},T) -> #point3d{x=X*T,y=Y*T,z=Z*T}.