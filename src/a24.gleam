import argv
import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/pair
import gleam/string
import stdin.{stdin}
import util.{parse, unwrap}

pub fn main() {
  case argv.load().arguments {
    [] -> a()
    _ -> b()
  }
  |> io.println
}

fn in() {
  let i =
    stdin()
    |> iterator.map(string.trim)

  let s =
    i
    |> iterator.take_while(fn(s) { !string.is_empty(s) })
    |> iterator.map(fn(s) { string.split_once(s, ": ") |> unwrap })
    |> iterator.to_list
    |> dict.from_list
    |> dict.map_values(fn(_k, v) { v |> parse })

  let o =
    i
    |> iterator.map(fn(s) {
      let assert [a, op, b, _, t] = string.split(s, " ")
      let op = case op {
        "AND" -> int.bitwise_and
        "OR" -> int.bitwise_or
        "XOR" -> int.bitwise_exclusive_or
        _ -> panic
      }
      #(op, a, b, t)
    })
    |> iterator.to_list

  #(s, o)
}

fn resolve(state, ops, rest) {
  case ops, rest {
    [], [] -> state
    [h, ..tl], r -> {
      let #(op, a, b, t) = h
      let da = dict.get(state, a)
      let db = dict.get(state, b)
      case da, db {
        Ok(va), Ok(vb) -> resolve(dict.insert(state, t, op(va, vb)), tl, r)
        _, _ -> resolve(state, tl, [h, ..r])
      }
    }
    [], r -> resolve(state, r, [])
  }
}

fn a() {
  let #(state, ops) = in()

  resolve(state, ops, [])
  |> sorted("z")
  |> list.map(pair.second)
  |> list.map(int.to_string)
  |> string.join("")
  |> int.base_parse(2)
  |> unwrap
  |> int.to_string
}

fn sorted(state, prefix) {
  state
  |> dict.filter(fn(k, _v) { string.starts_with(k, prefix) })
  |> dict.to_list
  |> list.sort(fn(a, b) { string.compare(pair.first(a), pair.first(b)) })
  |> list.reverse
}

fn b() {
  ""
}
