import argv
import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option.{None, Some}
import gleam/order
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

fn find(map, pos, dir, tc, hist, options, end, max) {
  let o =
    next(map, pos, dir)
    |> list.map(fn(o) {
      let #(p, d, c) = o
      #(p, d, c + tc, set.insert(hist, p))
    })
    |> list.fold(options, fn(acc, o) {
      let #(p, d, c, h) = o
      acc
      |> dict.upsert(#(p, d), fn(a) {
        case a {
          None -> #(c, h)
          Some(#(cx, hx)) ->
            case int.compare(c, cx) {
              order.Lt -> #(c, h)
              order.Gt -> #(cx, hx)
              order.Eq -> #(c, set.union(h, hx))
            }
        }
      })
    })
  let next =
    o
    |> dict.fold(#(max, []), fn(acc, k, v) {
      let #(m, l) = acc
      let #(p, d) = k
      let #(c, h) = v
      case int.compare(c, m) {
        order.Lt -> #(c, [#(p, d, c, h)])
        order.Gt -> #(m, l)
        order.Eq -> #(m, [#(p, d, c, h), ..l])
      }
    })
    |> pair.second
  case next {
    [] -> #(max, hist)
    [#(p, d, c, h), ..] if p == end ->
      find(map, p, d, c, set.union(h, hist), o |> dict.delete(#(p, d)), end, c)
    [#(p, d, c, h), ..] ->
      find(map, p, d, c, h, o |> dict.delete(#(p, d)), end, max)
  }
}

fn f() {
  let #(map, start, end) = in()
  find(
    map,
    start,
    Right,
    0,
    set.from_list([start]),
    dict.new(),
    end,
    999_999_999,
  )
}

fn a() {
  f()
  |> pair.first
  |> int.to_string
}

fn b() {
  f()
  |> pair.second
  |> set.size
  |> int.to_string
}
