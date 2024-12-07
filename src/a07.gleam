import argv
import gleam/float
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/pair
import gleam/string
import gleam_community/maths/elementary.{logarithm_10}
import stdin.{stdin}
import util.{parse, unwrap}

pub fn main() {
  case argv.load().arguments {
    [] -> a()
    _ -> b()
  }
  |> list.map(pair.first)
  |> int.sum
  |> int.to_string
  |> io.println
}

fn in() {
  stdin()
  |> iterator.map(fn(l) {
    let assert [l, ..r] =
      l
      |> string.split(" ")
      |> list.map(fn(s) { s |> string.replace(":", "") |> string.trim |> parse })
    #(l, r)
  })
  |> iterator.to_list
}

fn check(result, current, remaining) {
  case remaining {
    [] if result == current -> True
    [hd, ..tl] ->
      check(result, current + hd, tl) || check(result, current * hd, tl)
    _ -> False
  }
}

fn concat_check(result, current, remaining) {
  case remaining {
    [] if result == current -> True
    [hd, ..tl] ->
      concat_check(result, current + hd, tl)
      || concat_check(result, current * hd, tl)
      || concat_check(result, concat(current, hd), tl)
    _ -> False
  }
}

fn concat(a, b) {
  let digits = float.ceiling(logarithm_10(int.to_float(b + 1)) |> unwrap)
  float.round(unwrap(int.power(10, digits))) * a + b
}

fn a() {
  in()
  |> list.filter(fn(ex) {
    let assert #(res, [hd, ..tl]) = ex
    check(res, hd, tl)
  })
}

fn b() {
  in()
  |> list.filter(fn(ex) {
    let assert #(res, [hd, ..tl]) = ex
    concat_check(res, hd, tl)
  })
}
