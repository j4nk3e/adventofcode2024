import argv
import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/result
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

fn parse() {
  let #(a, b) =
    stdin()
    |> iterator.to_list
    |> list.map(fn(l) { string.split_once(l, on: " ") })
    |> result.values
    |> list.unzip()
  let order_int = fn(x) {
    x
    |> list.map(fn(s) {
      s
      |> string.trim
      |> int.parse
    })
    |> result.values
    |> list.sort(by: int.compare)
  }
  let s_a = order_int(a)
  let s_b = order_int(b)
  #(s_a, s_b)
}

fn a() {
  let #(a, b) = parse()
  list.zip(a, b)
  |> list.map(fn(x) {
    let #(a, b) = x
    int.absolute_value(b - a)
  })
  |> int.sum
  |> int.to_string
}

fn b() {
  let #(a, b) = parse()
  let g =
    list.group(b, by: id)
    |> dict.map_values(fn(_k, v) { list.length(v) })

  list.map(a, fn(x) {
    let c =
      dict.get(g, x)
      |> result.unwrap(0)
    c * x
  })
  |> int.sum
  |> int.to_string
}
