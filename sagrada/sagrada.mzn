int: BOARD_SIZE_X;
int: BOARD_SIZE_Y;

enum VALUES;
enum COLOURS;

array[int] of VALUES: dice_values;
array[int] of COLOURS: dice_colours;

set of int: rows  = 1..BOARD_SIZE_X;
set of int: rows0 = 0..BOARD_SIZE_X;
set of int: cols  = 1..BOARD_SIZE_Y;
set of int: cols0 = 0..BOARD_SIZE_Y;

% TODO: add board restrictions.
array[rows, cols] of 0..card(VALUES): value_restrictions;
array[rows, cols] of 0..card(COLOURS): colour_restrictions;

% TODO: add goals.

constraint assert(length(dice_colours) = length(dice_values), "Error: dismatched number of dice in the game.");

int: num_dice = length(dice_colours);
int: EMPTY = 0;
set of int: dice = 1..num_dice;
set of int: dice0 = 0..num_dice;

array[dice] of var rows0: pos_x;                  % map dice id to x-coordinate of its position
array[dice] of var cols0: pos_y;                  % map dice id to y-coordinate of its position
array[rows, cols] of var dice0: board_content;    % map coordinates of the cell to the id of the die placed on it

% Channelling constraints.
constraint forall(d in dice) (
  forall(r in rows) (
    forall(c in cols) (
      board_content[r,c] = d <-> pos_x[d] = r /\ pos_y[d] = c
    )
  )
);

% No repetition of dice on the board.
include "alldifferent_except_0.mzn";
constraint alldifferent_except_0([board_content[r,c] | r in rows, c in cols]);

% Adjacency conditions.
predicate areDistinct(rows: r1, cols: c1, rows: r2, cols: c2) = (
  let { var dice0: d1 = board_content[r1,c1]; var dice0: d2 = board_content[r2,c2]; } in
    (d1 > EMPTY /\ d2 > EMPTY) -> (
      dice_values[d1] != dice_values[d2] /\ dice_colours[d1] != dice_colours[d2]
    )
);

constraint forall(r in rows) (
  forall(c in 1..BOARD_SIZE_Y-1) (areDistinct(r, c, r, c+1))
);
constraint forall(c in cols) (
  forall(r in 1..BOARD_SIZE_X-1) (areDistinct(r, c, r+1, c))
);

% Board config restrictions.
constraint forall(r in rows) (
  forall(c in cols) (
    (value_restrictions[r,c] > 0 -> value_restrictions[r,c] = dice_values[board_content[r,c]]) /\
    (colour_restrictions[r,c] > 0 -> colour_restrictions[r,c] = dice_colours[board_content[r,c]])
  )
);

% solve satisfy;
var int: total_dots_on_board = sum([if board_content[r,c] > EMPTY then dice_values[board_content[r,c]] else 0 endif | r in rows, c in cols]);
solve maximize total_dots_on_board;
