import argv
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option
import gleam/regex
import gleam/string
import stdin.{stdin}
import util.{parse, unwrap}

pub fn main() {
  case argv.load().arguments {
    [] -> a()
    _ -> b()
  }
  |> list.map(fn(t) {
    let #(a, b) = t
    a * 3 + b
  })
  |> int.sum
  |> int.to_string
  |> io.println
}

fn in() {
  let s =
    stdin()
    |> iterator.to_list
    |> string.join("")
  regex.compile(
    "Button A: X\\+(\\d+), Y\\+(\\d+)\\sButton B: X\\+(\\d+), Y\\+(\\d+)\\sPrize: X=(\\d+), Y=(\\d+)",
    with: regex.Options(case_insensitive: False, multi_line: True),
  )
  |> unwrap
  |> regex.scan(s)
  |> list.map(fn(match) { match.submatches |> option.values |> list.map(parse) })
}

fn play(ax, ay, bx, by, px, py) {
  let a = px * by - py * bx
  let b = py * ax - px * ay
  let div = ax * by - ay * bx
  case a % div, b % div {
    0, 0 -> Ok(#(a / div, b / div))
    _, _ -> Error(Nil)
  }
}

fn a() {
  in()
  |> list.filter_map(fn(l) {
    let assert [ax, ay, bx, by, px, py] = l
    play(ax, ay, bx, by, px, py)
  })
}

fn b() {
  in()
  |> list.filter_map(fn(l) {
    let assert [ax, ay, bx, by, px, py] = l
    play(ax, ay, bx, by, px + 10_000_000_000_000, py + 10_000_000_000_000)
  })
}
