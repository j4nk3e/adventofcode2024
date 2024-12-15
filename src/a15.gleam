import argv
import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import stdin.{stdin}
import util.{unwrap}

pub fn main() {
  case argv.load().arguments {
    [] -> a()
    _ -> b()
  }
  |> io.println
}

type Pos {
  Box
  Robot
  Wall
}

type Direction {
  N
  E
  S
  W
}

fn in() {
  let in =
    stdin()
    |> iterator.map(string.trim)

  let map =
    in
    |> iterator.index
    |> iterator.take_while(fn(l) { pair.first(l) != "" })
    |> iterator.flat_map(fn(row) {
      let #(line, y) = row
      line
      |> string.to_graphemes
      |> iterator.from_list
      |> iterator.index
      |> iterator.filter_map(fn(col) {
        let #(char, x) = col
        let f = case char {
          "O" -> Ok(Box)
          "#" -> Ok(Wall)
          "@" -> Ok(Robot)
          _ -> Error(Nil)
        }
        f
        |> result.map(fn(f) { #(#(x, y), f) })
      })
    })
    |> iterator.to_list
  let robot =
    map |> list.find(fn(r) { pair.second(r) == Robot }) |> unwrap |> pair.first
  let map = dict.from_list(map) |> dict.delete(robot)

  let moves = parse_moves(in)
  #(map, robot, moves)
}

fn parse_moves(in) {
  in
  |> iterator.to_list
  |> string.join("")
  |> string.to_graphemes
  |> list.map(fn(c) {
    case c {
      "^" -> N
      ">" -> E
      "v" -> S
      "<" -> W
      _ -> panic
    }
  })
}

fn score(p) {
  let #(x, y) = p
  x + y * 100
}

fn move(map, robot, moves) {
  case moves {
    [] -> map
    [dir, ..tl] -> {
      let #(map, robot) = push(map, robot, dir)
      move(map, robot, tl)
    }
  }
}

fn next(p, dir) {
  let #(x, y) = p
  case dir {
    N -> #(x, y - 1)
    E -> #(x + 1, y)
    S -> #(x, y + 1)
    W -> #(x - 1, y)
  }
}

fn push(map, robot, dir) {
  let n = next(robot, dir)
  let m = map |> dict.get(n)
  case m {
    Error(_) -> #(map, n)
    Ok(Wall) -> #(map, robot)
    Ok(Box) ->
      case push_box(map, n, dir) {
        Error(_) -> #(map, robot)
        Ok(p) -> {
          #(map |> dict.delete(n) |> dict.insert(p, Box), n)
        }
      }
    _ -> panic
  }
}

fn push_box(map, box, dir) {
  let n = next(box, dir)
  let m = map |> dict.get(n)
  case m {
    Error(_) -> Ok(n)
    Ok(Box) -> push_box(map, n, dir)
    Ok(Wall) -> Error(Nil)
    _ -> panic
  }
}

fn a() {
  let #(map, robot, moves) = in()

  map
  |> move(robot, moves)
  |> dict.filter(fn(_k, v) { v == Box })
  |> dict.keys
  |> list.map(score)
  |> int.sum
  |> int.to_string
}

type PosB {
  BoxW
  BoxE
  RobotB
  WallB
}

fn in_b() {
  let in =
    stdin()
    |> iterator.map(string.trim)

  let map =
    in
    |> iterator.take_while(fn(l) { l != "" })
    |> iterator.to_list
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(char, x) {
        case char {
          "O" -> [#(#(x * 2, y), BoxW), #(#(x * 2 + 1, y), BoxE)]
          "#" -> [#(#(x * 2, y), WallB), #(#(x * 2 + 1, y), WallB)]
          "@" -> [#(#(x * 2, y), RobotB)]
          _ -> []
        }
      })
      |> list.flatten
    })
    |> list.flatten
  let robot =
    map |> list.find(fn(r) { pair.second(r) == RobotB }) |> unwrap |> pair.first
  let map = dict.from_list(map) |> dict.delete(robot)

  let moves = parse_moves(in)
  #(map, robot, moves)
}

fn move_b(map, robot, moves) {
  case moves {
    [] -> #(map, robot)
    [dir, ..tl] -> {
      let #(map, robot) = push_b(map, robot, dir)
      move_b(map, robot, tl)
    }
  }
}

fn push_b(map, robot, dir) {
  let n = next(robot, dir)
  case push_box_b(map, [n], dir, []) {
    Error(_) -> #(map, robot)
    Ok(boxes) -> #(move_boxes(map, boxes, dir), n)
  }
}

fn move_boxes(map, boxes, dir) {
  let dropped = dict.drop(map, boxes)
  boxes
  |> list.fold(dropped, fn(acc, p) {
    let old = dict.get(map, p) |> unwrap
    acc |> dict.insert(next(p, dir), old)
  })
}

fn print(m) {
  let #(map, robot) = m
  let map = map |> dict.insert(robot, RobotB)
  let #(w, h) =
    map
    |> dict.keys
    |> list.reduce(fn(a, b) {
      #(
        int.max(pair.first(a), pair.first(b)),
        int.max(pair.second(a), pair.second(b)),
      )
    })
    |> unwrap
  iterator.range(0, h)
  |> iterator.each(fn(y) {
    iterator.range(0, w)
    |> iterator.map(fn(x) {
      case dict.get(map, #(x, y)) {
        Ok(WallB) -> "#"
        Ok(BoxE) -> "]"
        Ok(BoxW) -> "["
        Ok(RobotB) -> "@"
        Error(_) -> "."
      }
    })
    |> iterator.to_list
    |> string.join("")
    |> io.println
  })
  m
}

fn push_box_b(map, boxes, dir, acc) {
  case boxes {
    [] -> Ok(acc)
    [p, ..tl] -> {
      let q = map |> dict.get(p)
      case q {
        Error(_) -> push_box_b(map, tl, dir, acc)
        Ok(BoxW) -> {
          let be = next(p, E)
          let acc = [p, be, ..acc]
          case dir {
            N | S ->
              push_box_b(map, [next(p, dir), next(be, dir), ..tl], dir, acc)
            E -> push_box_b(map, [next(be, E), ..tl], dir, acc)
            W -> panic
          }
        }
        Ok(BoxE) -> {
          let bw = next(p, W)
          let acc = [p, bw, ..acc]
          case dir {
            N | S ->
              push_box_b(map, [next(p, dir), next(bw, dir), ..tl], dir, acc)
            W -> push_box_b(map, [next(bw, W), ..tl], dir, acc)
            E -> panic
          }
        }
        Ok(WallB) -> Error(Nil)
        _ -> panic
      }
    }
  }
}

fn b() {
  let #(map, robot, moves) = in_b()

  map
  |> move_b(robot, moves)
  |> print()
  |> pair.first
  |> dict.filter(fn(_k, v) { v == BoxW })
  |> dict.keys
  |> list.map(score)
  |> int.sum
  |> int.to_string
}
