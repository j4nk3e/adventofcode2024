import argv
import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/pair
import gleam/result
import gleam/set
import gleam/string
import stdin.{stdin}
import util.{unwrap}

pub fn main() {
  case argv.load().arguments {
    [_] -> b()
    _ -> a()
  }
  |> io.println
}

type Maze {
  Start
  Path
}

fn in() {
  let map =
    stdin()
    |> iterator.map(string.trim)
    |> iterator.index
    |> iterator.flat_map(fn(row) {
      let #(line, y) = row
      line
      |> string.to_graphemes
      |> iterator.from_list
      |> iterator.index
      |> iterator.filter_map(fn(col) {
        let #(char, x) = col
        let f = case char {
          "S" -> Ok(Start)
          "E" | "." -> Ok(Path)
          _ -> Error(Nil)
        }
        f
        |> result.map(fn(f) { #(#(x, y), f) })
      })
    })
    |> iterator.to_list

  let start =
    map |> list.find(fn(r) { pair.second(r) == Start }) |> unwrap |> pair.first

  map |> list.map(pair.first) |> set.from_list |> make_path(start, 0, [])
}

fn next(p, map) {
  let #(x, y) = p
  [#(x + 1, y), #(x - 1, y), #(x, y + 1), #(x, y - 1)]
  |> list.find(fn(p) { map |> set.contains(p) })
}

fn make_path(map, from, g, acc) {
  let acc = [#(from, g), ..acc]
  case next(from, map) {
    Ok(a) -> make_path(map |> set.delete(from), a, g + 1, acc)
    _ -> acc |> list.reverse
  }
}

const gain = 100

fn find_cheats(path, map, dur, count) {
  case path {
    [#(#(px, py), g), ..tl] -> {
      let n =
        tl
        |> list.filter(fn(e) {
          let #(#(ex, ey), p) = e
          let md = int.absolute_value(ex - px) + int.absolute_value(ey - py)
          p - gain - md >= g && md <= dur
        })
        |> list.length
      find_cheats(tl, map, dur, count + n)
    }
    [] -> count
  }
}

fn cheat(path, dur) {
  find_cheats(path, path |> dict.from_list, dur, 0)
  |> int.to_string
}

fn a() {
  cheat(in(), 2)
}

fn b() {
  cheat(in(), 20)
}
