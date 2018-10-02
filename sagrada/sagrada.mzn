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
set of int: dice = 1..num_dice;

array[dice] of var rows: pos_x;                  % map dice id to x-coordinate of its position
array[dice] of var cols: pos_y;                  % map dice id to y-coordinate of its position
array[rows, cols] of var dice: board_content;    % map coordinates of the cell to the id of the die placed on it

% Channelling constraint.
include "inverse.mzn";
constraint inverse(
  [board_content[r,c] | r in rows, c in cols],
  [(pos_x[d] - 1) * BOARD_SIZE_X + pos_y[d] | d in dice]
);

% No two dice can be placed in the same square;
include "alldifferent.mzn";
constraint alldifferent([pos_x[d] * BOARD_SIZE_Y + pos_y[d] | d in dice]);

% Adjacency conditions.
constraint forall(r in rows) (
  forall(c in 1..BOARD_SIZE_Y-1) (dice_values[board_content[r, c]] != dice_values[board_content[r, c+1]] /\ dice_colours[board_content[r, c]] != dice_colours[board_content[r, c+1]] )
);
constraint forall(c in cols) (
  forall(r in 1..BOARD_SIZE_X-1) (dice_values[board_content[r, c]] != dice_values[board_content[r+1, c]] /\ dice_colours[board_content[r, c]] != dice_colours[board_content[r+1, c]] )
);

solve satisfy;
