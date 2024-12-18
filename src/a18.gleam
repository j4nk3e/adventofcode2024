import argv
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/pair
import gleam/set
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
  stdin()
  |> iterator.map(fn(s) { s |> string.trim |> string.split_once(",") |> unwrap })
  |> iterator.map(fn(p) { #(pair.first(p) |> parse, pair.second(p) |> parse) })
  |> iterator.to_list
}

fn neighbors(p, size) {
  let #(x, y) = p
  let #(xm, ym) = size
  [#(x + 1, y), #(x - 1, y), #(x, y + 1), #(x, y - 1)]
  |> list.filter(fn(p) {
    let #(x, y) = p
    x >= 0 && x <= xm && y >= 0 && y <= ym
  })
}

fn find(map, old, new, exit, g) {
  let old = set.union(old, new)
  case set.contains(new, exit) {
    True -> g
    False -> {
      let n =
        new
        |> set.to_list
        |> list.flat_map(neighbors(_, exit))
        |> set.from_list
        |> set.difference(old)
        |> set.difference(map)
      case set.is_empty(n) {
        True -> -1
        False -> find(map, old, n, exit, g + 1)
      }
    }
  }
}

fn a() {
  let map =
    in()
    |> list.take(1024)
    |> set.from_list

  map
  |> find(set.new(), set.from_list([#(0, 0)]), #(70, 70), 0)
  |> int.to_string
}

fn binary_search(l, s, e) {
  case l {
    [] -> #(-1, -1)
    [p] -> p
    _ -> {
      let len = list.length(l)
      let #(a, b) = list.split(l, len / 2)
      let sb = a |> set.from_list |> set.union(s)
      let r = find(sb, set.new(), set.from_list([#(0, 0)]), e, 0)
      case r {
        -1 -> binary_search(a, s, e)
        _ -> binary_search(b, sb, e)
      }
    }
  }
}

fn b() {
  let map = in()

  let #(x, y) = map |> binary_search(set.new(), #(70, 70))
  string.join([x, y] |> list.map(int.to_string), ",")
}
