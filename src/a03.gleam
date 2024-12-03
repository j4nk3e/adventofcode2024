import argv
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option
import gleam/pair
import gleam/regex
import gleam/string
import stdin.{stdin}
import util.{parse, re, reduce}

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
  |> string.join("")
}

fn a() {
  let mul = re("mul\\((\\d+),(\\d+)\\)")
  in()
  |> regex.scan(with: mul)
  |> list.map(fn(m) {
    m.submatches
    |> option.values
    |> list.map(parse)
    |> reduce(int.multiply)
  })
  |> int.sum
  |> int.to_string
}

fn b() {
  let mul = re("mul\\((\\d+),(\\d+)\\)|don't\\(\\)|do\\(\\)")
  in()
  |> regex.scan(with: mul)
  |> list.fold(#(True, 0), fn(acc, m) {
    let #(on, sum) = acc
    case m.content {
      "don't()" -> #(False, sum)
      "do()" -> #(True, sum)
      _ if on -> {
        let s =
          m.submatches
          |> option.values
          |> list.map(parse)
          |> reduce(int.multiply)
        #(on, s + sum)
      }
      _ -> #(on, sum)
    }
  })
  |> pair.second
  |> int.to_string
}
