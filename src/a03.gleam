import argv
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option
import gleam/pair
import gleam/regex
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
  |> string.join("")
}

fn a() {
  let mul =
    regex.compile("mul\\((\\d+),(\\d+)\\)", with: regex.Options(False, False))
    |> result.lazy_unwrap(fn() { panic })
  parse()
  |> regex.scan(with: mul)
  |> list.map(fn(m) {
    m.submatches
    |> option.values
    |> list.map(fn(n) {
      n
      |> int.parse
      |> result.lazy_unwrap(fn() { panic })
    })
    |> list.reduce(int.multiply)
    |> result.lazy_unwrap(fn() { panic })
  })
  |> int.sum
  |> int.to_string
}

fn b() {
  let mul =
    regex.compile(
      "mul\\((\\d+),(\\d+)\\)|don't\\(\\)|do\\(\\)",
      with: regex.Options(False, False),
    )
    |> result.lazy_unwrap(fn() { panic })
  parse()
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
          |> list.map(fn(n) {
            n
            |> int.parse
            |> result.lazy_unwrap(fn() { panic })
          })
          |> list.reduce(int.multiply)
          |> result.lazy_unwrap(fn() { panic })
        #(on, s + sum)
      }
      _ -> #(on, sum)
    }
  })
  |> pair.second
  |> int.to_string
}
