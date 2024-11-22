import argv
import gleam/io
import gleam/iterator
import gleam/list
import gleam/result
import stdin.{stdin}

pub fn main() {
  case argv.load().arguments {
    [] -> a()
    _ -> b()
  }
  |> io.println
}

fn a() {
  stdin()
  |> iterator.to_list
  |> list.first
  |> result.unwrap("")
}

fn b() {
  stdin()
  |> iterator.to_list
  |> list.last
  |> result.unwrap("")
}
