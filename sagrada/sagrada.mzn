int: BOARD_SIZE_X;
int: BOARD_SIZE_Y;

enum VALUES;
enum COLOURS;

set of int: rows = 1..BOARD_SIZE_X;
set of int: cols = 1..BOARD_SIZE_Y;

% TODO: accommodate redundant and insufficient number of dice.

% TODO: add board restrictions.

% TODO: add goals.

array[int] of VALUES: dice_values;
array[int] of COLOURS: dice_colours;

constraint assert(length(dice_colours) = length(dice_values), "Error: dismatched number of dice in the game.");

int: num_dice = length(dice_colours);
int: EMPTY = 0;
set of int: dice = 1..num_dice;
set of int: dice0 = 0..num_dice;

array[dice] of var rows: pos_x;                  % map dice id to x-coordinate of its position
array[dice] of var cols: pos_y;                  % map dice id to y-coordinate of its position
array[rows, cols] of var dice: board_content;    % map coordinates of the cell to the id of the die placed on it

% Channelling constraint.
constraint forall(r in rows) (
  forall(c in cols) (board_content[r,c] > EMPTY <-> let { var dice: d = board_content[r,c]; } in pos_x[d] = r /\ pos_y[d] = c)
);

% no repetition of dice on the board.
include "alldifferent_except_0.mzn";
constraint alldifferent_except_0([board_content[r,c] | r in rows, c in cols]);

% Adjacency conditions.
predicate areDistinct(rows: r1, cols: c1, rows: r2, cols: c2) = (
  let { var dice: d1 = board_content[r1,c1]; var dice: d2 = board_content[r2,c2]; } in
  dice_values[d1] != dice_values[d2] /\
  dice_colours[d1] != dice_colours[d2]
);

constraint forall(r in rows) (
  forall(c in 1..BOARD_SIZE_Y-1) (areDistinct(r, c, r, c+1))
);
constraint forall(c in cols) (
  forall(r in 1..BOARD_SIZE_X-1) (areDistinct(r, c, r+1, c))
);

solve satisfy;
