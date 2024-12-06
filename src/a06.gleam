import argv
import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/pair
import gleam/set
import gleam/string
import parallel_map.{MatchSchedulersOnline, list_pmap}
import stdin.{stdin}
import util.{id, unwrap}

type Field {
  Barrier
  Free
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
  let l =
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

  let size = l |> list.last |> unwrap |> pair.first
  let f = l |> dict.from_list
  let start =
    dict.filter(f, fn(_k, v) { v == Start })
    |> dict.to_list
    |> list.first
    |> unwrap
    |> pair.first
  let s =
    l
    |> list.filter(fn(f) { { f |> pair.second } == Barrier })
    |> list.map(pair.first)
    |> set.from_list
  #(s, size, start)
}

fn move(pos, dir, f, size, history) {
  let next = pos |> next(dir)
  let #(x, y) = pos
  let #(w, h) = size
  case x > w || y > h || x < 0 || y < 0 {
    True -> history
    False ->
      case set.contains(f, next) {
        True -> move(pos, turn(dir), f, size, history)
        False -> move(next, dir, f, size, history |> set.insert(pos))
      }
  }
}

fn a() {
  let #(f, size, start) = in()
  move(start, N, f, size, set.new())
  |> set.size
}

fn loop(pos, dir, f, size, history) {
  let next = pos |> next(dir)
  let #(x, y) = pos
  let #(w, h) = size
  case x > w || y > h || x < 0 || y < 0 {
    True -> False
    False ->
      case set.contains(f, next) {
        True if dir == N ->
          case set.contains(history, pos) {
            True -> True
            False -> loop(pos, turn(dir), f, size, history |> set.insert(pos))
          }
        True -> loop(pos, turn(dir), f, size, history)
        False -> loop(next, dir, f, size, history)
      }
  }
}

fn b() {
  let #(f, size, start) = in()
  move(start, N, f, size, set.from_list([]))
  |> set.filter(fn(p) { p != start })
  |> set.to_list
  |> list_pmap(
    fn(p) { loop(start, N, f |> set.insert(p), size, set.from_list([])) },
    MatchSchedulersOnline,
    100,
  )
  |> list.map(unwrap)
  |> list.filter(id)
  |> list.length
}

pub fn main() {
  case argv.load().arguments {
    [] -> a()
    _ -> b()
  }
  |> int.to_string
  |> io.println
}
