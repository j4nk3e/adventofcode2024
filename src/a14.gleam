import argv
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option
import gleam/pair
import gleam/regex
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
  let l =
    stdin()
    |> iterator.to_list
  let re =
    regex.compile(
      "p=(-?\\d+),(-?\\d+) v=(-?\\d+),(-?\\d+)",
      with: regex.Options(case_insensitive: False, multi_line: True),
    )
    |> unwrap

  l
  |> list.map(fn(s) {
    let m =
      regex.scan(re, s)
      |> list.first
      |> unwrap

    let assert [px, py, vx, vy] =
      m.submatches |> option.values |> list.map(parse)
    #(#(px, py), #(vx, vy))
  })
}

fn add(p, v, b) {
  let #(x, y) = p
  let #(dx, dy) = v
  let #(bx, by) = b
  #({ x + dx + bx } % bx, { y + dy + by } % by)
}

fn move(l, b) {
  case l {
    [] -> []
    [#(p, v), ..t] -> [#(add(p, v, b), v), ..move(t, b)]
  }
}

fn cycle(l, b, n) {
  case n {
    0 -> l
    _ -> cycle(move(l, b), b, n - 1)
  }
}

fn safety(l, a, b, c, d, bounds) {
  let #(w, h) = bounds
  case l {
    [] -> {
      io.debug(#(a, b, c, d))
      a * b * c * d
    }
    [#(p, _v), ..t] ->
      case p {
        #(x, y) if x < w / 2 && y < h / 2 -> safety(t, a + 1, b, c, d, bounds)
        #(x, y) if x > w / 2 && y < h / 2 -> safety(t, a, b + 1, c, d, bounds)
        #(x, y) if x < w / 2 && y > h / 2 -> safety(t, a, b, c + 1, d, bounds)
        #(x, y) if x > w / 2 && y > h / 2 -> safety(t, a, b, c, d + 1, bounds)
        _ -> safety(t, a, b, c, d, bounds)
      }
  }
}

fn a() {
  let b = #(101, 103)
  in()
  |> cycle(b, 100)
  |> safety(0, 0, 0, 0, b)
  |> int.to_string
}

fn print(l, b) {
  let #(w, h) = b
  let s = l |> list.map(pair.first) |> set.from_list
  let lines =
    iterator.range(0, h)
    |> iterator.map(fn(y) {
      iterator.range(0, w)
      |> iterator.map(fn(x) {
        let on = s |> set.contains(#(x, y))
        case on {
          False -> "."
          True -> "#"
        }
      })
      |> iterator.to_list
      |> string.join("")
    })
    |> iterator.to_list
  case
    lines
    |> list.any(fn(l) { string.contains(l, "#############") })
  {
    True -> {
      io.println(lines |> string.join("\n"))
      True
    }
    False -> False
  }
}

fn tree(l, b, n) {
  let t = print(l, b)
  case t {
    True -> n
    False -> tree(move(l, b), b, n + 1)
  }
}

fn b() {
  let b = #(101, 103)
  in()
  |> tree(b, 0)
  |> int.to_string
}
