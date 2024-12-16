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
    [] -> a()
    _ -> b()
  }
  |> io.println
}

type Maze {
  Path
  Start
  End
}

type Direction {
  Up
  Right
  Down
  Left
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
          "S" -> Ok(Start)
          "E" -> Ok(End)
          "." -> Ok(Path)
          _ -> Error(Nil)
        }
        f
        |> result.map(fn(f) { #(#(x, y), f) })
      })
    })
    |> iterator.to_list
  let start =
    map |> list.find(fn(r) { pair.second(r) == Start }) |> unwrap |> pair.first
  let end =
    map |> list.find(fn(r) { pair.second(r) == End }) |> unwrap |> pair.first
  let map =
    dict.from_list(map)
    |> dict.keys
    |> set.from_list

  #(map, start, end)
}

const turn = 1001

const move = 1

fn next(map, pos, dir) {
  let #(x, y) = pos
  case dir {
    Right -> [
      #(#(x + 1, y), Right, move),
      #(#(x, y + 1), Down, turn),
      #(#(x, y - 1), Up, turn),
    ]
    Down -> [
      #(#(x, y + 1), Down, move),
      #(#(x + 1, y), Right, turn),
      #(#(x - 1, y), Left, turn),
    ]
    Left -> [
      #(#(x - 1, y), Left, move),
      #(#(x, y + 1), Down, turn),
      #(#(x, y - 1), Up, turn),
    ]
    Up -> [
      #(#(x, y - 1), Up, move),
      #(#(x + 1, y), Right, turn),
      #(#(x - 1, y), Left, turn),
    ]
  }
  |> list.filter(fn(o) {
    let #(pos, _d, _c) = o
    set.contains(map, pos)
  })
}

fn cost(o) {
  let #(_, _, c, _) = o
  c
}

fn comp_cost(a, b) {
  int.compare(cost(a), cost(b))
}

fn find(map, pos, dir, end, options, tc, hist, max) {
  let n =
    next(map, pos, dir)
    |> list.map(fn(o) {
      let #(p, d, c) = o
      #(p, d, c + tc, set.insert(hist, p))
    })
  let o =
    list.flatten([options, n])
    |> list.group(fn(o) {
      let #(p, d, _c, _h) = o
      #(p, d)
    })
    |> dict.map_values(fn(_k, v) {
      let o =
        v
        |> list.sort(comp_cost)

      let #(p, d, c, _) =
        o
        |> list.first
        |> unwrap
      let h =
        o
        |> list.take_while(fn(o) {
          let #(_p, _d, cx, _h) = o
          cx == c
        })
        |> list.fold(set.new(), fn(acc, o) {
          let #(_p, _d, _c, h) = o
          set.union(acc, h)
        })

      #(p, d, c, h)
    })
    |> dict.values
    |> list.sort(comp_cost)
  case o {
    [] -> #(-1, hist)
    [#(_, _, c, _), ..] if c > max -> #(max, hist)
    [#(p, d, c, h), ..t] if p == end ->
      find(map, p, d, end, t, c, set.union(h, hist), c)
    [#(p, d, c, h), ..t] -> find(map, p, d, end, t, c, h, max)
  }
}

fn a() {
  let #(map, start, end) = in()
  find(map, start, Right, end, [], 0, set.from_list([start]), 999_999_999)
  |> pair.first
  |> int.to_string
}

fn b() {
  let #(map, start, end) = in()
  find(map, start, Right, end, [], 0, set.from_list([start]), 999_999_999)
  |> pair.second
  |> set.size
  |> int.to_string
}
