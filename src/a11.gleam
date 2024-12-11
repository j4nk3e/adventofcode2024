import argv
import gleam/dict
import gleam/float
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import gleam_community/maths/elementary.{logarithm_10}
import stdin.{stdin}
import util.{id, parse, unwrap}

pub fn main() {
  case argv.load().arguments {
    [] -> a()
    _ -> b()
  }
  |> io.println
}

fn in() {
  stdin()
  |> iterator.to_list
  |> string.join(" ")
  |> string.split(" ")
  |> list.map(string.trim)
  |> list.map(parse)
}

fn rules(e) {
  let digits =
    float.ceiling(logarithm_10(int.to_float(e + 1)) |> unwrap) |> float.round
  case e {
    0 -> [1]
    _ if digits % 2 == 0 -> {
      let pow =
        int.power(10, int.to_float(digits) /. 2.0) |> unwrap |> float.round
      let l = e / pow
      let r = e % pow
      [l, r]
    }
    _ -> [e * 2024]
  }
}

fn a() {
  let l = in()
  iterator.range(from: 1, to: 25)
  |> iterator.to_list
  |> list.fold(l, fn(a, _i) { a |> list.flat_map(rules) })
  |> list.length
  |> int.to_string
}

fn b() {
  let d =
    in() |> list.group(id) |> dict.map_values(fn(_k, v) { list.length(v) })
  iterator.range(from: 1, to: 75)
  |> iterator.fold(d, fn(acc, _i) {
    acc
    |> dict.fold(dict.new(), fn(acc, k, v) {
      rules(k)
      |> list.fold(acc, fn(acc, n) {
        acc
        |> dict.upsert(n, fn(q) {
          case q {
            None -> v
            Some(r) -> v + r
          }
        })
      })
    })
  })
  |> dict.values
  |> int.sum
  |> int.to_string
}
