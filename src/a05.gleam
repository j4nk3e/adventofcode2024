import argv
import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/order
import gleam/pair
import gleam/result
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
  let lines =
    stdin()
    |> iterator.map(string.trim)
    |> iterator.index
    |> iterator.to_list
  let split =
    lines
    |> list.find(fn(l) { l |> pair.first |> string.is_empty })
    |> unwrap
    |> pair.second
  let #(deps, stacks) = lines |> list.map(pair.first) |> list.split(split)
  let deps =
    deps
    |> list.map(fn(l) {
      let assert [from, to] = l |> string.split("|")
      #(from |> parse, to |> parse)
    })
    |> list.group(pair.first)
    |> dict.map_values(fn(_k, v) { v |> list.map(pair.second) })
  let stacks =
    stacks
    |> list.filter(fn(l) { !string.is_empty(l) })
    |> list.map(fn(l) { l |> string.split(",") |> list.map(parse) })
  #(deps, stacks)
}

fn compare(a, b, deps) {
  deps |> dict.get(b) |> result.unwrap([]) |> list.contains(any: a)
}

fn check(stack, deps, before) {
  case stack {
    [hd, ..tail] ->
      !list.any(before, fn(x) { compare(x, hd, deps) })
      && check(tail, deps, [hd, ..before])
    [] -> True
  }
}

fn mid(l) {
  let len = list.length(l)
  l
  |> iterator.from_list
  |> iterator.at(len / 2)
  |> unwrap
}

fn a() {
  let #(deps, stacks) = in()
  stacks
  |> list.filter(fn(s) { check(s, deps, []) })
  |> list.map(mid)
  |> int.sum
  |> int.to_string
}

fn b() {
  let #(deps, stacks) = in()
  stacks
  |> list.filter(fn(s) { !check(s, deps, []) })
  |> list.map(fn(s) {
    s
    |> list.sort(by: fn(a, b) {
      case compare(a, b, deps) {
        False -> order.Lt
        True -> order.Gt
      }
    })
    |> mid
  })
  |> int.sum
  |> int.to_string
}
