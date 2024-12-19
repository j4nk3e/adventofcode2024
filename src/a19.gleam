import argv
import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/pair
import gleam/string
import stdin.{stdin}

pub fn main() {
  case argv.load().arguments {
    [] -> a()
    _ -> b()
  }
  |> io.println
}

fn in() {
  let i = stdin()
  let patterns =
    i
    |> iterator.take(2)
    |> iterator.to_list
    |> string.join("")
    |> string.trim
    |> string.split(", ")

  let designs = i |> iterator.to_list |> list.map(string.trim)
  #(patterns, designs)
}

fn check_prefix(patterns, prefix, design) {
  let d = design |> string.drop_left(string.length(prefix))
  case d {
    "" -> True
    _ -> check(patterns, d)
  }
}

fn check(patterns, design) {
  patterns
  |> list.filter(string.starts_with(design, _))
  |> list.any(check_prefix(patterns, _, design))
}

fn a() {
  let #(patterns, designs) = in()
  designs |> list.filter(check(patterns, _)) |> list.length |> int.to_string
}

fn count(patterns, designs, cache, sum) {
  case designs {
    [] -> #(cache, sum)
    [design, ..tl] ->
      case dict.get(cache, design) {
        Error(_) -> {
          let #(c, s) =
            patterns
            |> list.filter(string.starts_with(design, _))
            |> list.fold(#(cache, 0), fn(acc, prefix) {
              let #(c, sa) = acc
              let d = design |> string.drop_left(string.length(prefix))
              case d {
                "" -> #(c, sa + 1)
                _ -> {
                  let #(c, s) = count(patterns, [d], c, 0)
                  #(dict.insert(c, d, s), sa + s)
                }
              }
            })
          count(patterns, tl, c, s + sum)
        }
        Ok(n) -> count(patterns, tl, cache, n + sum)
      }
  }
}

fn b() {
  let #(patterns, designs) = in()
  count(patterns, designs, dict.new(), 0) |> pair.second |> int.to_string
}
