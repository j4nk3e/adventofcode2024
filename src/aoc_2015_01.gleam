import argv
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/string
import stdin.{stdin}

pub fn main() {
  case argv.load().arguments {
    [] -> a()
    _ -> b()
  }
  |> io.print
}

fn a() {
  stdin()
  |> iterator.to_list
  |> list.flat_map(string.to_graphemes)
  |> list.fold(from: 0, with: fn(i, c) {
    case c {
      "(" -> i + 1
      ")" -> i - 1
      _ -> panic
    }
  })
  |> int.to_string
}

fn b() {
  stdin()
  |> iterator.to_list
  |> list.flat_map(string.to_graphemes)
  |> find(0, 0)
  |> int.to_string
}

fn find(iter, current, pos) {
  case current {
    -1 -> pos
    _ ->
      case iter {
        ["(", ..rest] -> find(rest, current + 1, pos + 1)
        [")", ..rest] -> find(rest, current - 1, pos + 1)
        _ -> panic
      }
  }
}
