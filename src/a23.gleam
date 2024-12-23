import argv
import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
import gleam/set
import gleam/string
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
  stdin()
  |> iterator.map(string.trim)
  |> iterator.filter(fn(s) { s != "" })
  |> iterator.map(string.split_once(_, "-"))
  |> iterator.map(unwrap)
  |> iterator.fold(dict.new(), fn(d, t) {
    let #(a, b) = t
    d
    |> dict.upsert(a, fn(o) {
      case o {
        None -> set.from_list([b])
        option.Some(s) -> set.insert(s, b)
      }
    })
    |> dict.upsert(b, fn(o) {
      case o {
        None -> set.from_list([a])
        option.Some(s) -> set.insert(s, a)
      }
    })
  })
}

fn find_lan(d) {
  d
  |> dict.map_values(fn(k, v) { find_group(d, k, v) })
  |> dict.values
  |> list.flatten
  |> list.filter(fn(l) { list.length(l) == 3 })
  |> list.filter(fn(l) { list.any(l, string.starts_with(_, "t")) })
}

fn is_edge(d, a, b) {
  dict.get(d, a) |> unwrap |> set.contains(b)
}

fn find_group(d, k, v) {
  v
  |> set.to_list
  |> list.combination_pairs
  |> list.filter(fn(p) { is_edge(d, pair.first(p), pair.second(p)) })
  |> list.map(fn(p) { [k, pair.first(p), pair.second(p)] })
}

fn a() {
  let l =
    in()
    |> find_lan()
    |> list.length

  l / 3
  |> int.to_string
}

fn bron_kerbosch(acc, p, r, x) {
  case list.is_empty(p) && set.is_empty(x) {
    True -> [r, ..acc]
    False ->
      case p {
        [] -> acc
        [#(n, c), ..tl] -> {
          acc
          |> bron_kerbosch(tl, r, set.insert(x, n))
          |> bron_kerbosch(
            list.filter(p, fn(q) { set.contains(c, pair.first(q)) }),
            set.insert(r, n),
            set.intersection(x, c),
          )
        }
      }
  }
}

fn largest_lan(g) {
  bron_kerbosch([], dict.to_list(g), set.new(), set.new())
  |> list.reduce(fn(a, b) {
    case set.size(a) > set.size(b) {
      True -> a
      _ -> b
    }
  })
  |> unwrap
}

fn b() {
  in()
  |> largest_lan()
  |> set.to_list
  |> list.sort(string.compare)
  |> string.join(",")
}
