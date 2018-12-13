%%
%%  IBM Ponder This, Oct 2018
%%

int: N = 8; % number of points
set of int: POINTS = 1..N;

%var 1..50: L1;
%var 1..50: L2;

set of int: rows = 1..30;
set of int: cols = 1..30;

% constraint L1 * L2 <= 300;

array[POINTS] of var rows: pos_x;
array[POINTS] of var cols: pos_y;

%constraint max([pos_x[p] * pos_y[p] | p in POINTS]) <= 600;

% No two points can share the same coordinates.
include "alldifferent.mzn";
%constraint alldifferent([pos_x[p] * L2 + pos_y[p] | p in POINTS]);
constraint forall(p1, p2 in POINTS where p1 < p2) (pos_x[p1] != pos_x[p2] \/ pos_y[p1] != pos_y[p2]);

% No three points are collinear.
constraint forall(p1, p2, p3 in POINTS where p1 < p2 /\ p2 < p3) (
  (pos_x[p1] - pos_x[p2]) * (pos_y[p3] - pos_y[p2]) != (pos_x[p3] - pos_x[p2]) * (pos_y[p1] - pos_y[p2])
);

% Compute areas of all triangles formed by triplets of points.
% Use area_eqvs here for integer arithmetic, where the real area equals sqrt(area_eqv)/4 .
array[POINTS, POINTS, POINTS] of var int: area_eqvs;
constraint forall(p1, p2, p3 in POINTS where p1 < p2 /\ p2 < p3) (
  area_eqvs[p1, p2, p3] = let {
  var int: a = (pos_x[p1] - pos_x[p2]) * (pos_x[p1] - pos_x[p2]) + (pos_y[p1] - pos_y[p2]) * (pos_y[p1] - pos_y[p2]);
  var int: b = (pos_x[p2] - pos_x[p3]) * (pos_x[p2] - pos_x[p3]) + (pos_y[p2] - pos_y[p3]) * (pos_y[p2] - pos_y[p3]);
  var int: c = (pos_x[p3] - pos_x[p1]) * (pos_x[p3] - pos_x[p1]) + (pos_y[p3] - pos_y[p1]) * (pos_y[p3] - pos_y[p1]);
} in
    ((a + b + c) * (a + b + c) - 2 * (a * a + b * b + c * c))
);

% Areas are all different.
constraint alldifferent([
  area_eqvs[p1, p2, p3] | p1, p2, p3 in POINTS where p1 < p2 /\ p2 < p3
]);

% Break symmetries.
% constraint L1 <= L2;
constraint pos_x[1] <= pos_y[1];
constraint pos_x[1] <= max(pos_x);
constraint pos_y[1] <= max(pos_y);
include "lex_less.mzn";
include "lex_lesseq.mzn";
constraint forall(p1, p2 in POINTS where p1 < p2) (lex_less([pos_x[p1], pos_y[p1]],[pos_x[p2], pos_y[p2]]));
constraint lex_lesseq(pos_x, reverse(pos_x));
constraint lex_lesseq(pos_y, reverse(pos_y));

include "global_cardinality_low_up.mzn";
constraint global_cardinality_low_up(pos_x, rows, [0 | r in rows], [1 | r in rows]);
constraint global_cardinality_low_up(pos_y, cols, [0 | c in cols], [1 | c in cols]);

%solve minimize L1 * L2;
solve satisfy;

output
  ["Points: "] ++
  ["(\(pos_x[p]),\(pos_y[p])) " | p in POINTS] ++
  ["\n"] ++
  ["Area of [(\(pos_x[p1]),\(pos_y[p1])), (\(pos_x[p2]),\(pos_y[p2])), (\(pos_x[p3]),\(pos_y[p3]))]: \(sqrt(area_eqvs[p1, p2, p3]) / 4)\n"| p1, p2, p3 in POINTS where p1 < p2 /\ p2 < p3]
;
