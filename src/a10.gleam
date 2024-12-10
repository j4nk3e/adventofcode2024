import argv
import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/pair
import gleam/string
import stdin.{stdin}
import util.{parse}

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
      let #(h, x) = col
      #(#(x, y), parse(h))
    })
  })
  |> iterator.to_list
  |> dict.from_list
}

fn next(pos, h, map) {
  let #(x, y) = pos
  [#(x + 1, y), #(x - 1, y), #(x, y - 1), #(x, y + 1)]
  |> list.map(fn(pos) { #(pos, dict.get(map, pos)) })
  |> list.filter_map(fn(p) {
    let hn = p |> pair.second
    case Ok(h + 1) == hn {
      True -> Ok(p |> pair.first)
      False -> Error(Nil)
    }
  })
}

fn a() {
  let map = in()
  map
  |> dict.filter(fn(_k, v) { v == 0 })
  |> dict.keys
  |> list.map(fn(start) {
    iterator.range(from: 0, to: 8)
    |> iterator.fold(from: [start], with: fn(acc, n) {
      let r =
        acc
        |> list.flat_map(fn(e) { next(e, n, map) })
        |> list.unique
      r
    })
  })
  |> list.map(list.length)
  |> int.sum
  |> int.to_string
}

fn b() {
  let map = in()
  map
  |> dict.filter(fn(_k, v) { v == 0 })
  |> dict.keys
  |> list.map(fn(start) {
    iterator.range(from: 0, to: 8)
    |> iterator.fold(from: [start], with: fn(acc, n) {
      let r =
        acc
        |> list.flat_map(fn(e) { next(e, n, map) })
      r
    })
  })
  |> list.map(list.length)
  |> int.sum
  |> int.to_string
}
