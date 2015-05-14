-module(box3d).
-import(point3d, [new/3]).
-compile(export_all).
-record(box3d,{origin=#point3d{},corner=#point3d{}}).

new(#point3d{}=Origin,#point3d{}=Corner) -> #box3d{origin=Origin,corner=Corner}.