int: BOARD_SIZE_X;
int: BOARD_SIZE_Y;

enum VALUES;
enum COLOURS;

% TODO: add board restrictions.

% TODO: add goals.

set of int: rows = 1..BOARD_SIZE_X;
set of int: cols = 1..BOARD_SIZE_Y;

array[int] of VALUES: dice_values;
array[int] of COLOURS: dice_colours;

constraint assert(length(dice_colours) = length(dice_values), "Error: dismatched number of dice in the game.");

int: num_dice = length(dice_colours);
set of int: dice = 1..num_dice;

array[dice] of var rows: pos_x;
array[dice] of var cols: pos_y;

% No two dice can be placed in the same square;
include "alldifferent.mzn";
constraint alldifferent([pos_x[d] * BOARD_SIZE_Y + pos_y[d] | d in dice]);

% TODO: adjacency conditions.

solve satisfy;
