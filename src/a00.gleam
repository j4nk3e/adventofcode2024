import argv
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import stdin.{stdin}

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
}

fn a() {
  in()
  |> list.length
  |> int.to_string
}

fn b() {
  in()
  |> list.length
  |> int.to_string
}
