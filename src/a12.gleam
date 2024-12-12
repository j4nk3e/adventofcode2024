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
import util.{id}

pub fn main() {
  case argv.load().arguments {
    [] -> a()
    _ -> b()
  }
  |> io.println
}

fn in() {
  stdin()
  |> iterator.index
  |> iterator.flat_map(fn(row) {
    let #(line, y) = row
    line
    |> string.trim
    |> string.to_graphemes
    |> iterator.from_list
    |> iterator.index
    |> iterator.map(fn(col) {
      let #(c, x) = col
      #(#(x, y), c)
    })
  })
  |> iterator.to_list
  |> dict.from_list
}

fn adjacent(p) {
  let #(x, y) = p
  [#(x, y - 1), #(x + 1, y), #(x, y + 1), #(x - 1, y)]
}

fn flood(d, l) {
  let f = d |> dict.to_list |> list.first
  case f {
    Error(_) -> l
    Ok(#(p, c)) -> {
      let #(d, i, c) = island(d, [p], [], c)
      flood(d, [#(i, c), ..l])
    }
  }
}

fn island(d, active, contained, c) {
  let next =
    active
    |> list.flat_map(adjacent)
    |> list.unique
    |> list.filter(fn(p) { dict.get(d, p) == Ok(c) })
  let cont = list.append(active, contained)
  let d = d |> dict.drop(active)
  case next {
    [] -> #(d, cont, c)
    [_, ..] -> island(d, next, cont, c)
  }
}

fn score(d, l) {
  let #(i, c) = l
  let a = i |> list.length
  let b =
    i
    |> list.map(fn(p) {
      let n =
        adjacent(p)
        |> list.map(fn(s) { d |> dict.get(s) == Ok(c) })
        |> list.count(id)
      4 - n
    })
    |> int.sum
  a * b
}

fn a() {
  let m = in()
  m
  |> flood([])
  |> list.map(fn(e) { score(m, e) })
  |> int.sum
  |> int.to_string
}

type Orientation {
  N
  E
  S
  W
}

fn adjacent_b(p) {
  let #(x, y) = p
  [#(#(x, y - 1), N), #(#(x + 1, y), E), #(#(x, y + 1), S), #(#(x - 1, y), W)]
}

fn score_b(d, l) {
  let #(i, c) = l
  let a = i |> list.length
  let b =
    i
    |> list.flat_map(fn(p) {
      adjacent_b(p)
      |> list.filter_map(fn(a) {
        case dict.get(d, pair.first(a)) {
          Ok(q) if q == c -> Error(Nil)
          _ -> Ok(a)
        }
      })
    })
    |> list.group(pair.second)
    |> dict.map_values(fn(o, l) {
      let s = l |> list.map(pair.first) |> set.from_list
      s
      |> set.filter(fn(p) {
        let #(x, y) = p
        let n = case o {
          N | S -> #(x - 1, y)
          E | W -> #(x, y - 1)
        }
        !set.contains(s, n)
      })
      |> set.size
    })
    |> dict.values
    |> int.sum
  a * b
}

fn b() {
  let m = in()
  m
  |> flood([])
  |> list.map(fn(e) { score_b(m, e) })
  |> int.sum
  |> int.to_string
}
