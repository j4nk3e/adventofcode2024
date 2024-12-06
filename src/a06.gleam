import argv
import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/pair
import gleam/set
import gleam/string
import stdin.{stdin}
import util.{unwrap}

type Field {
  Free
  Barrier
  Start
}

type Direction {
  N
  E
  S
  W
}

fn turn(dir) {
  case dir {
    N -> E
    E -> S
    S -> W
    W -> N
  }
}

fn next(pos, dir) {
  let #(x, y) = pos
  case dir {
    N -> #(x, y - 1)
    E -> #(x + 1, y)
    S -> #(x, y + 1)
    W -> #(x - 1, y)
  }
}

fn in() {
  let f =
    stdin()
    |> iterator.index
    |> iterator.flat_map(fn(row) {
      let #(line, y) = row
      line
      |> string.to_graphemes
      |> iterator.from_list
      |> iterator.filter(fn(a) { a != "\n" })
      |> iterator.index
      |> iterator.map(fn(col) {
        let #(char, x) = col
        let f = case char {
          "#" -> Barrier
          "." -> Free
          "^" -> Start
          _ -> panic
        }
        #(#(x, y), f)
      })
    })
    |> iterator.to_list
    |> dict.from_list
  let start =
    dict.filter(f, fn(_k, v) { v == Start })
    |> dict.to_list
    |> list.first
    |> unwrap
    |> pair.first
  #(f, start)
}

fn move(pos, dir, f, history) {
  let next = pos |> next(dir)
  case dict.get(f, next) {
    Error(_) -> history |> set.insert(pos)
    Ok(Barrier) -> move(pos, turn(dir), f, history)
    Ok(_) -> move(next, dir, f, history |> set.insert(pos))
  }
}

fn a() {
  let #(f, start) = in()
  move(start, N, f, set.new())
}

fn loop(pos, dir, f, history) {
  let next = pos |> next(dir)
  case dict.get(f, next) {
    Error(_) -> False
    Ok(Barrier) if dir == N ->
      case set.contains(history, pos) {
        True -> True
        False -> loop(pos, turn(dir), f, history |> set.insert(pos))
      }
    Ok(Barrier) -> loop(pos, turn(dir), f, history)
    Ok(_) -> loop(next, dir, f, history)
  }
}

fn b() {
  let #(f, start) = in()
  move(start, N, f, set.from_list([]))
  |> set.filter(fn(p) {
    p != start
    && loop(start, N, f |> dict.insert(p, Barrier), set.from_list([]))
  })
}

pub fn main() {
  case argv.load().arguments {
    [] -> a()
    _ -> b()
  }
  |> set.size
  |> int.to_string
  |> io.println
}
