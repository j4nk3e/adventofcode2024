import argv
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import stdin.{stdin}

pub fn main() {
  case argv.load().arguments {
    [] -> a()
    _ -> b()
  }
  |> io.println
}

fn parse() {
  stdin()
  |> iterator.to_list
  |> list.map(fn(l) {
    l
    |> string.split(on: " ")
    |> list.map(string.trim)
    |> list.map(int.parse)
    |> result.values
  })
  |> list.filter(fn(l) { !list.is_empty(l) })
}

fn a() {
  parse()
  |> list.filter(monotonic)
  |> list.length
  |> int.to_string
}

fn monotonic(l) {
  let diffs =
    l
    |> list.window_by_2
    |> list.map(fn(p) { pair.second(p) - pair.first(p) })

  diffs |> list.all(fn(d) { d >= 1 && d <= 3 })
  || diffs |> list.all(fn(d) { d <= -1 && d >= -3 })
}

fn b() {
  parse()
  |> list.filter(fn(l) {
    list.range(from: 0, to: list.length(l))
    |> list.any(fn(i) {
      l
      |> iterator.from_list
      |> iterator.index
      |> iterator.filter(fn(q) { q |> pair.second != i })
      |> iterator.map(pair.first)
      |> iterator.to_list
      |> monotonic
    })
  })
  |> list.length
  |> int.to_string
}
