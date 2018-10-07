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

array[rows, cols] of 0..card(VALUES): value_restrictions;
array[rows, cols] of 0..card(COLOURS): colour_restrictions;

% TODO: add goals.

COLOURS: private_goal;
set of PUBLIC_GOAL_CHOICES: public_goals;

enum PUBLIC_GOAL_CHOICES = {DISTINCT_COLOUR_IN_A_ROW, DISTINCT_COLOUR_IN_A_COL, PAIR_OF_ONE_TWO, PAIR_OF_THREE_FOUR};
array[1..card(PUBLIC_GOAL_CHOICES)] of 1..5: PUBLIC_GOAL_POINTS = [5, 4, 2, 2];


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

var 1..6*BOARD_SIZE_X*BOARD_SIZE_Y: private_obj;

constraint private_obj = sum(r in rows, c in cols) (if dice_colours[board_content[r,c]] = private_goal then dice_values[board_content[r,c]] else 0 endif);

var int: empty_cell_penalty = - sum(r in rows, c in cols) (board_content[r,c] = EMPTY);

var int: public_obj;

predicate alldifferent(array[int] of var int: arr) = forall(i, j in index_set(arr)) (arr[i] != arr[j]);

predicate evaluate_public_obj(var int: obj, array[int, int] of var dice0: board, set of PUBLIC_GOAL_CHOICES: goals) = (
 let { var int: po1 = if DISTINCT_COLOUR_IN_A_ROW in PUBLIC_GOAL_CHOICES then sum(r in rows) (alldifferent([board[r,c] | c in cols])) else 0 endif }
 in
 po1 * PUBLIC_GOAL_POINTS[DISTINCT_COLOUR_IN_A_ROW] = obj
);

constraint evaluate_public_obj(public_obj, board_content, public_goals);

var int: total_obj;
constraint total_obj = private_obj + public_obj + empty_cell_penalty;

solve maximize total_obj;

