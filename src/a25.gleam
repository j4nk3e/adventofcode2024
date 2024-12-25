import argv
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/string
import gleam_community/maths/combinatorics
import stdin.{stdin}
import util.{unwrap}

pub fn main() {
  case argv.load().arguments {
    [] -> a()
    _ -> b()
  }
  |> io.println
}

fn in() {
  let #(locks, keys) =
    stdin()
    |> iterator.map(string.trim)
    |> iterator.filter(fn(s) { !string.is_empty(s) })
    |> iterator.to_list
    |> list.sized_chunk(7)
    |> list.partition(fn(lines) {
      lines |> list.first |> unwrap |> string.starts_with("#")
    })
  let l =
    locks
    |> list.map(parse(
      _,
      iterator.repeat(-1) |> iterator.take(5) |> iterator.to_list,
    ))
  let k =
    keys
    |> list.map(parse(
      _,
      iterator.repeat(-1) |> iterator.take(5) |> iterator.to_list,
    ))
  #(l, k)
}

fn parse(rows, count) {
  case rows {
    [] -> count
    [r, ..tl] ->
      parse(
        tl,
        r
          |> string.to_graphemes
          |> list.map(fn(c) {
            case c {
              "#" -> 1
              _ -> 0
            }
          })
          |> list.map2(count, int.add),
      )
  }
}

fn a() {
  let #(k, l) = in()

  combinatorics.cartesian_product(k, l)
  |> list.filter(fn(p) {
    let #(k, l) = p
    list.zip(k, l)
    |> list.all(fn(p) {
      let #(a, b) = p
      a + b <= 5
    })
  })
  |> list.length
  |> int.to_string
}

fn b() {
  ""
}
